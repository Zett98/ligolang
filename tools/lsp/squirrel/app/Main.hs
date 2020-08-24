
import           Control.Concurrent
import           Control.Arrow
import           Control.Concurrent.STM
import           Control.Exception                     as E
import           Control.Lens
import           Control.Monad

import           Data.Default
-- import           Data.Foldable
import qualified Data.Text                             as Text
import           Data.Text                                     (Text)
import           Data.String                                   (fromString)
import           Data.String.Interpolate                       (i)

import qualified Language.Haskell.LSP.Control          as CTRL
import qualified Language.Haskell.LSP.Core             as Core
import           Language.Haskell.LSP.Diagnostics
import           Language.Haskell.LSP.Messages         as Msg
import qualified Language.Haskell.LSP.Types            as J
import qualified Language.Haskell.LSP.Types.Lens       as J
import qualified Language.Haskell.LSP.Utility          as U
import           Language.Haskell.LSP.VFS

import           System.Exit
import qualified System.Log                            as L

import           Duplo.Error
import           Duplo.Pretty
import           Duplo.Tree (collect)

import           Range
import           Product
import           AST                                           hiding (def)
import qualified AST.Find                              as Find
import Data.Maybe (fromMaybe)
-- import           Error

main :: IO ()
main = do
  -- return ()
  -- for_ [1.. 100] \_ -> do
  --   print . length . show . pp =<< sample' "../../../src/test/recognises/loop.ligo"
  errCode <- mainLoop
  exit errCode

mainLoop :: IO Int
mainLoop = do
    chan <- atomically newTChan :: IO (TChan FromClientMessage)

    let
      callbacks = Core.InitializeCallbacks
        { Core.onInitialConfiguration = const $ Right ()
        , Core.onConfigurationChange = const $ Right ()
        , Core.onStartup = \lFuns -> do
            _ <- forkIO $ eventLoop lFuns chan
            return Nothing
        }

    Core.setupLogger (Just "log.txt") [] L.INFO
    CTRL.run callbacks (lspHandlers chan) lspOptions (Just "log.txt")
  `catches`
    [ Handler \(e :: SomeException) -> do
        print e
        return 1
    ]

syncOptions :: J.TextDocumentSyncOptions
syncOptions = J.TextDocumentSyncOptions
  { J._openClose         = Just True
  , J._change            = Just J.TdSyncIncremental
  , J._willSave          = Just False
  , J._willSaveWaitUntil = Just False
  , J._save              = Just $ J.SaveOptions $ Just False
  }

lspOptions :: Core.Options
lspOptions = def
  { Core.textDocumentSync       = Just syncOptions
  , Core.executeCommandCommands = Just ["lsp-hello-command"]
  }

lspHandlers :: TChan FromClientMessage -> Core.Handlers
lspHandlers rin = def
  { Core.initializedHandler                       = Just $ passHandler rin NotInitialized
  , Core.definitionHandler                        = Just $ passHandler rin ReqDefinition
  , Core.referencesHandler                        = Just $ passHandler rin ReqFindReferences
  , Core.didOpenTextDocumentNotificationHandler   = Just $ passHandler rin NotDidOpenTextDocument
  , Core.didSaveTextDocumentNotificationHandler   = Just $ passHandler rin NotDidSaveTextDocument
  , Core.didChangeTextDocumentNotificationHandler = Just $ passHandler rin NotDidChangeTextDocument
  , Core.didCloseTextDocumentNotificationHandler  = Just $ passHandler rin NotDidCloseTextDocument
  , Core.cancelNotificationHandler                = Just $ passHandler rin NotCancelRequestFromClient
  , Core.responseHandler                          = Just $ responseHandlerCb rin
  , Core.codeActionHandler                        = Just $ passHandler rin ReqCodeAction
  , Core.executeCommandHandler                    = Just $ passHandler rin ReqExecuteCommand
  , Core.completionHandler                        = Just $ passHandler rin ReqCompletion
  , Core.completionResolveHandler                 = Just $ passHandler rin ReqCompletionItemResolve
  }

passHandler :: TChan FromClientMessage -> (a -> FromClientMessage) -> Core.Handler a
passHandler rin c notification = do
  atomically $ writeTChan rin (c notification)

responseHandlerCb :: TChan FromClientMessage -> Core.Handler J.BareResponseMessage
responseHandlerCb _rin resp = do
  U.logs $ "******** got ResponseMessage, ignoring:" ++ show resp

send :: Core.LspFuncs () -> FromServerMessage -> IO ()
send = Core.sendFunc

nextID :: Core.LspFuncs () -> IO J.LspId
nextID = Core.getNextReqId

eventLoop :: Core.LspFuncs () -> TChan FromClientMessage -> IO ()
eventLoop funs chan = do
  forever do
    msg <- atomically (readTChan chan)

    U.logs [i|Client: ${msg}|]

    case msg of
      RspFromClient {} -> do
        return ()

      NotInitialized _notif -> do
        let
          registration = J.Registration
            "lsp-haskell-registered"
            J.WorkspaceExecuteCommand
            Nothing
          registrations = J.RegistrationParams $ J.List [registration]

        rid <- nextID funs
        send funs
          $ ReqRegisterCapability
          $ fmServerRegisterCapabilityRequest rid registrations

      NotDidOpenTextDocument notif -> do
        let
          doc = notif
            ^.J.params
             .J.textDocument
             .J.uri

          ver = notif
            ^.J.params
             .J.textDocument
             .J.version

        collectErrors funs
          (J.toNormalizedUri doc)
          (J.uriToFilePath doc)
          (Just ver)

      NotDidChangeTextDocument notif -> do
        let
          doc = notif
            ^.J.params
             .J.textDocument
             .J.uri

        collectErrors funs
          (J.toNormalizedUri doc)
          (J.uriToFilePath doc)
          (Just 0)

      ReqDefinition req -> do
        stopDyingAlready funs req do
          let uri = req^.J.params.J.textDocument.J.uri
          let pos = posToRange $ req^.J.params.J.position
          tree <- loadFromVFS funs uri
          case Find.definitionOf pos tree of
            Just defPos -> do
              respondWith funs req RspDefinition $ J.MultiLoc [J.Location uri $ rangeToLoc defPos]
            Nothing -> do
              respondWith funs req RspDefinition $ J.MultiLoc []

      ReqFindReferences req -> do
        stopDyingAlready funs req do
          let uri = req^.J.params.J.textDocument.J.uri
          let pos = posToRange $ req^.J.params.J.position
          tree <- loadFromVFS funs uri
          case Find.referencesOf pos tree of
            Just refs -> do
              let locations = J.Location uri . rangeToLoc <$> refs
              respondWith funs req RspFindReferences $ J.List locations
            Nothing -> do
              respondWith funs req RspFindReferences $ J.List []

      ReqCompletion req -> do
        stopDyingAlready funs req $ do
          U.logs $ "got completion request: " <> show req
          let uri = req ^. J.params . J.textDocument . J.uri
          let pos = posToRange $ req ^. J.params . J.position
          tree <- loadFromVFS funs uri
          let completions = fmap toCompletionItem . fromMaybe [] $ complete pos tree
          respondWith funs req RspCompletion . J.Completions . J.List $ completions

      -- Additional callback executed after completion was made, currently no-op
      ReqCompletionItemResolve req -> do
        stopDyingAlready funs req $ do
          U.logs $ "got completion resolve request: " <> show req
          respondWith funs req RspCompletionItemResolve (req ^. J.params)

      _ -> U.logs "unknown msg"

respondWith
  :: Core.LspFuncs ()
  -> J.RequestMessage J.ClientMethod req rsp
  -> (J.ResponseMessage rsp -> FromServerMessage)
  -> rsp
  -> IO ()
respondWith funs req wrap rsp = Core.sendFunc funs $ wrap $ Core.makeResponseMessage req rsp

stopDyingAlready :: Core.LspFuncs () -> J.RequestMessage m a b -> IO () -> IO ()
stopDyingAlready funs req = flip catch \(e :: SomeException) -> do
  Core.sendErrorResponseS (Core.sendFunc funs) (req^.J.id.to J.responseId) J.InternalError
    $ fromString
    $ "this happened: " ++ show e

posToRange :: J.Position -> Range
posToRange (J.Position l c) = Range (l + 1, c + 1, 0) (l + 1, c + 1, 0) ""

rangeToLoc :: Range -> J.Range
rangeToLoc (Range (a, b, _) (c, d, _) _) =
  J.Range
    (J.Position (a - 1) (b - 1))
    (J.Position (c - 1) (d - 1))

loadFromVFS
  :: Core.LspFuncs ()
  -> J.Uri
  -> IO (LIGO Info')
loadFromVFS funs uri = do
  Just vf <- Core.getVirtualFileFunc funs $ J.toNormalizedUri uri
  let txt = virtualFileText vf
  let Just fin = J.uriToFilePath uri
  (tree, _) <- parse (Text fin txt)
  return $ addLocalScopes tree

-- loadByURI
--   :: J.Uri
--   -> IO (LIGO Info')
-- loadByURI uri = do
--   case J.uriToFilePath uri of
--     Just fin -> do
--       (tree, _) <- runParserM . recognise =<< toParseTree (Path fin)
--       return $ addLocalScopes tree
--     Nothing -> do
--       error $ "uriToFilePath " ++ show uri ++ " has failed. We all are doomed."

collectErrors
  :: Core.LspFuncs ()
  -> J.NormalizedUri
  -> Maybe FilePath
  -> Maybe Int
  -> IO ()
collectErrors funs uri path version = do
  case path of
    Just fin -> do
      (tree, errs) <- parse (Path fin)
      Core.publishDiagnosticsFunc funs 100 uri version
        $ partitionBySource
        $ map errorToDiag (errs <> map (getElem *** void) (collect tree))

    Nothing -> error "TODO: implement URI file loading"

errorToDiag :: (Range, Err Text a) -> J.Diagnostic
errorToDiag (getRange -> (Range (sl, sc, _) (el, ec, _) _), Err what) =
  J.Diagnostic
    (J.Range begin end)
    (Just J.DsError)
    Nothing
    (Just "ligo-lsp")
    (Text.pack [i|Expected #{what}|])
    (Just $ J.List[])
  where
    begin = J.Position (sl - 1) (sc - 1)
    end   = J.Position (el - 1) (ec - 1)

exit :: Int -> IO ()
exit 0 = exitSuccess
exit n = exitWith (ExitFailure n)
