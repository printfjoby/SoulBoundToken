%lang starknet
from starkware.cairo.common.uint256 import Uint256, uint256_sub
from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin, HashBuiltin
from starkware.cairo.common.bool import TRUE

const CREATOR = 0x00348f5537be66815eb7de63295fcb5d8b8b2ffe09bb712af4966db7cbb04a91;
const TEST_ACC1 = 0x00348f5537be66815eb7de63295fcb5d8b8b2ffe09bb712af4966db7cbb04a95;
const TEST_ACC2 = 0x3fe90a1958bb8468fb1b62970747d8a00c435ef96cda708ae8de3d07f1bb56b;
const TEST_TOKEN_ID = 123;
//const TOKEN_URI = "fr"


from src.ISBToken import ISBToken

@external
func __setup__() {

    // Deploy contract
    %{
        context.contract_address  = deploy_contract("./src/SBToken.cairo", [
               5338434412023108646027945078640, ## name:   CairoWorkshop
               17239,                            ## symbol: CW
               ids.CREATOR,
               ]).contract_address
    %}
    return ();
}



@external
func test_name{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    alloc_locals;

    tempvar contract_address;
    %{ ids.contract_address = context.contract_address %}

    // Read name
    let (token_name) = ISBToken.name(contract_address=contract_address);
        //%{ print(f"passing value: {ids.token_name}") %}
    assert token_name = 5338434412023108646027945078640;

    return ();
}


@external
func test_mint{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    alloc_locals;
    tempvar contract_address;
    %{ ids.contract_address = context.contract_address %}

    // Call as creator
    %{ stop_prank_callable = start_prank(ids.CREATOR, ids.contract_address) %}

    // Mint SBToken to TEST_ACC1
    let (new_token_id) = ISBToken.mint(contract_address=contract_address, owner=TEST_ACC1, owner_name='SAM', graduation_status=Uint256(1, 0) );
    // Check whether the first token id is 1
    assert new_token_id.low = 1;
        // %{ print(f"token_id: {ids.new_token_id.low}") %}
    %{ stop_prank_callable() %}

    // Check emited count is 1 after first minting
    let (emitted_count) = ISBToken.get_emitted_count(contract_address=contract_address);

        //%{ print(f"emitted count: {ids.emitted_count.low}") %}
    assert emitted_count.low = 1;
    
    //Check whether the token owner address is TEST_ACC1
    let (owner) = ISBToken.owner_of(contract_address=contract_address, token_id=new_token_id);

        //%{ print(f"owner: {ids.owner}") %}
    assert owner = TEST_ACC1;

    //Verify the Token Id, Owner Name, Graduation Status
    let (token_id, owner_name, graduation_status) = ISBToken.view_certificate(contract_address=contract_address, owner=TEST_ACC1);

        //%{ print(f"Token Id , Owner Name, Graduation Status are: {ids.token_id.low, ids.owner_name, ids.graduation_status.low }") %}

    assert token_id.low = 1;
    assert owner_name = 'SAM';
    assert graduation_status.low = 1;

    // Check whether minting can be done twice to same address. 
    %{ expect_revert(error_type="TRANSACTION_FAILED", error_message="Mint: Already minted to this owner") %}
    %{ stop_prank_callable = start_prank(ids.CREATOR, ids.contract_address) %}

    ISBToken.mint(contract_address=contract_address, owner=TEST_ACC1, owner_name='SAM', graduation_status=Uint256(1, 0) );
   
    %{ stop_prank_callable() %}

    return ();
}

@external
func test_mint_from_non_creator{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    alloc_locals;
    tempvar contract_address;
    %{ ids.contract_address = context.contract_address %}


    %{ expect_revert(error_type="TRANSACTION_FAILED", error_message="Mint: caller must be the owner") %}

    // Try minting from Test_ACC1
    %{ stop_prank_callable = start_prank(ids.TEST_ACC1, ids.contract_address) %}

    ISBToken.mint(contract_address=contract_address, owner=TEST_ACC1, owner_name='SAM', graduation_status=Uint256(1, 0) );
    
    %{ stop_prank_callable() %}

    return ();
}

@external
func test_mint_to_zero_address{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    alloc_locals;
    tempvar contract_address;
    %{ ids.contract_address = context.contract_address %}


    %{ expect_revert(error_type="TRANSACTION_FAILED", error_message="Mint: cannot mint to the zero address") %}
    
    //Minting to Zero address
    %{ stop_prank_callable = start_prank(ids.CREATOR, ids.contract_address) %}

    ISBToken.mint(contract_address=contract_address, owner=0, owner_name='SAM', graduation_status=Uint256(1, 0) );
   
    %{ stop_prank_callable() %}

    return ();
}

@external
func test_remove_token{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    alloc_locals;
    tempvar contract_address;
    %{ ids.contract_address = context.contract_address %}


    // Mint SBToken to TEST_ACC1
    %{ stop_prank_callable = start_prank(ids.CREATOR, ids.contract_address) %}
    let (new_token_id) = ISBToken.mint(contract_address=contract_address, owner=TEST_ACC1, owner_name='SAM', graduation_status=Uint256(1, 0) );
    %{ stop_prank_callable() %}


    // Call as creator
    %{ stop_prank_callable = start_prank(ids.CREATOR, ids.contract_address) %}

    // Remove SBToken owned by TEST_ACC1
    let (success)= ISBToken.remove_token(contract_address=contract_address, owner=TEST_ACC1 );

        assert success = TRUE;
    %{ stop_prank_callable() %}

    
    // //Check whether the token owner address is TEST_ACC1
    // let (owner) = ISBToken.owner_of(contract_address=contract_address, token_id=Uint256(1, 0));

    //     //%{ print(f"owner: {ids.owner}") %}
    // assert owner = 0;

    // let (token_id) = ISBToken.token_id_of(contract_address=contract_address, owner=TEST_ACC1);

    // assert token_id.low = 0;

    // Try burning already burned Token 
    %{ expect_revert(error_type="TRANSACTION_FAILED", error_message="Burn: token does not exist") %}
    %{ stop_prank_callable = start_prank(ids.CREATOR, ids.contract_address) %}

    ISBToken.remove_token(contract_address=contract_address, owner=TEST_ACC1 );
   
    %{ stop_prank_callable() %}

    return ();
}

@external
func test_unequip{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    alloc_locals;
    tempvar contract_address;
    %{ ids.contract_address = context.contract_address %}


    // Mint SBToken to TEST_ACC1
    %{ stop_prank_callable = start_prank(ids.CREATOR, ids.contract_address) %}
    let (new_token_id) = ISBToken.mint(contract_address=contract_address, owner=TEST_ACC1, owner_name='SAM', graduation_status=Uint256(1, 0) );
    %{ stop_prank_callable() %}


    // Call as SBToken Owner
    %{ stop_prank_callable = start_prank(ids.TEST_ACC1, ids.contract_address) %}

    // Remove SBToken owned by TEST_ACC1
    let (success)= ISBToken.unequip(contract_address=contract_address);
        assert success = TRUE;
    %{ stop_prank_callable() %}

    %{ expect_revert(error_type="TRANSACTION_FAILED", error_message="Burn: token does not exist") %}
    %{ stop_prank_callable = start_prank(ids.TEST_ACC1, ids.contract_address) %}

    ISBToken.unequip(contract_address=contract_address);
   
    %{ stop_prank_callable() %}

    return ();
}


