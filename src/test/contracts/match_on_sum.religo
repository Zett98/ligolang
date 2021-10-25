let a = {
  let ownerAddress : address = ("tz1TGu6TN5GSez2ndXXeDX6LgUDvLzPLqgYV" : address);
  switch (Tezos.get_contract_opt (ownerAddress): option(contract(unit))) {
  | Some (contract) => contract
  | None => (failwith ("Not a contract") : (contract(unit)))
  };
}
