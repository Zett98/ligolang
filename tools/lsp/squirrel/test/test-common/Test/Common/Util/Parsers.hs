module Test.Common.Util.Parsers
  ( checkFile
  ) where

import Control.Exception.Safe (try)

import AST.Parser (parsePreprocessed)
import AST.Scope (pattern FindContract, HasScopeForest, ScopeError, addShallowScopes)
import Parser (Failure, collectTreeErrors)
import ParseTree (Source (Path))
import Progress (noProgress)

import Test.Common.FixedExpectations (Expectation, HasCallStack, expectationFailure)
import Test.Common.Util (withoutLogger)

checkFile
  :: forall parser
   . (HasCallStack, HasScopeForest parser IO)
  => Bool
  -> FilePath
  -> Expectation
checkFile True (Path -> path) = withoutLogger \runLogger -> do
  res <- try (runLogger $ parsePreprocessed path)
  case res of
    Left (err :: Failure) -> expectationFailure $
      "Parsing failed, but it shouldn't have. " <>
      "Error: " <> show err <> "."
    Right c@(FindContract _file tree msgs) -> case msgs' of
      _ : _ -> expectationFailure $
        "Parsing failed, but it shouldn't have. " <>
        "Messages: " <> show msgs' <> "."
      [] -> do
        res' <- try @_ @ScopeError (addShallowScopes @parser noProgress c)
        case res' of
          Left err -> expectationFailure $
            "Scoping failed, but it shouldn't have. " <>
            "Error: " <> show err <> "."
          Right (FindContract _file tree' msgs'') -> case msgs''' of
            _ : _ -> expectationFailure $
              "Scoping failed, but it shouldn't have. " <>
              "Messages: " <> show msgs''' <> "."
            [] -> pure ()
            where
              msgs''' = collectTreeErrors tree' <> msgs''
      where
        msgs' = collectTreeErrors tree <> msgs
checkFile False (Path -> path) = withoutLogger \runLogger -> do
  res <- try @_ @Failure (runLogger $ parsePreprocessed path)
  case res of
    Right c@(FindContract _file tree []) -> case collectTreeErrors tree of
      [] -> expectationFailure "Parsing succeeded, but it shouldn't have."
      _ : _ -> do
        res' <- try @_ @ScopeError (addShallowScopes @parser noProgress c)
        case res' of
          Right (FindContract _file tree' []) -> case collectTreeErrors tree' of
            [] -> expectationFailure "Scoping succeeded, but it shouldn't have."
            _ : _ -> pure ()
          _ -> pure ()
    _ -> pure ()
