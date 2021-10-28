let a = {
  let ownerAddress : address = ("tz1TGu6TN5GSez2ndXXeDX6LgUDvLzPLqgYV" : address);
  let receiver : contract (unit) = switch (Tezos.get_contract_opt (ownerAddress): option(contract(unit))) {
  | Some (contract) => contract
  | None => (failwith ("Not a contract") : (contract(unit)))
  };
  (Tezos.transaction(unit, 10mutez, receiver), ("edpkuBknW28nW72KG6RoHtYW7p12T6GKc7nAbwYX5m8Wd9sDVC9yav" : key), "my string")
}
