// SPDX-License-Identifier: MIT

%lang starknet
from starkware.cairo.common.cairo_builtins import HashBuiltin, SignatureBuiltin
from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.common.math import assert_not_zero, assert_not_equal
from starkware.cairo.common.uint256 import Uint256, uint256_check, uint256_add, assert_uint256_lt

from openzeppelin.token.erc721.IERC721Metadata import IERC721Metadata
from openzeppelin.token.erc721.library import ERC721
from openzeppelin.introspection.erc165.library import ERC165
from openzeppelin.introspection.erc165.IERC165 import IERC165
from openzeppelin.security.safemath.library import SafeUint256


//
// Events
//

@event
func Minted(owner : felt, token_id:Uint256, owner_name : felt, graduation_status: Uint256) {
}

@event
func RemovedToken(from_: felt, tokenId: Uint256) {
}

@event
func Unequiped(from_: felt, tokenId: Uint256) {
}

//
// Storage
//

// Token name
@storage_var
func SBToken_name() -> (name: felt) {
}

// Token symbol
@storage_var
func SBToken_symbol() -> (symbol: felt) {
}

// Total number of tokens emitted
@storage_var
func SBToken_emitted_count() -> (emitted_count: Uint256) {
}

// Contract creator
@storage_var
func SBToken_creator() -> (creator: felt) {
}

// Mapping from owner to token id
@storage_var
func SBToken_tokenID(owner: felt) -> (token_id: Uint256) {
}


// Mapping from  token id to token owner
@storage_var
func SBToken_owner(token_id: Uint256) -> (owner: felt) {
}


// Mapping from  token id to token owner name
@storage_var
func SBToken_owner_name(token_id: Uint256) -> (owner_name: felt) {
}

// Mapping from  token id to token owner name
@storage_var
func Graduation_status(token_id: Uint256) -> (graduation_status: Uint256) {
}

// Mapping from  owner to mint status
@storage_var
func Mint_status(owner: felt) -> (mint_status: Uint256) {
}

    //
    // Constructor
    //

@constructor
func constructor{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        name_: felt, symbol_: felt, creator_:felt
    ) {
        let (caller) = get_caller_address();
        SBToken_name.write(name_);
        SBToken_symbol.write(symbol_);
        SBToken_creator.write(creator_);
        //SBToken_emitted_count.write(emitted_count_);
        return ();
    }

//
// Getters
//

@view
func supportsInterface{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*,range_check_ptr}(interfaceId: felt) -> (success: felt) {
    return ERC165.supports_interface(interfaceId);
}

@view
func name{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (name: felt) {
    return SBToken_name.read();
}

@view
func symbol{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
    symbol: felt
) {
    return SBToken_symbol.read();
}

@view
func get_emitted_count{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (emitted_count: Uint256) {
    return SBToken_emitted_count.read();
}

@view
func view_certificate{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(owner : felt) -> ( token_id:Uint256, owner_name:felt, graduation_status : Uint256
){
alloc_locals;
    let (token_id: Uint256) = SBToken_tokenID.read(owner=owner);
    // with_attr error_message("mint: token does not exists") {
    //      assert_not_zero(token_id);
    // }
    //add rest of returrns
    let (owner_name) = SBToken_owner_name.read(token_id);
    let (graduation_status) = Graduation_status.read(token_id);

    return (token_id = token_id, owner_name = owner_name, graduation_status = graduation_status);
}

// func token_uri{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
//     token_id: Uint256
// ) -> (token_uri: felt) {
//     let exists = _exists(token_id);
//     with_attr error_message("SBToken: URI query for nonexistent token") {
//         assert exists = TRUE;
//     }

//     // if tokenURI is not set, it will return 0
//     let (token_uri :felt) =  SBToken_tokenURI.read(token_id);
//     return (token_uri = token_uri);
// }

@view
func owner_of{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    token_id: Uint256
) -> (owner: felt) {
    alloc_locals;
    with_attr error_message("SBToken: token_id is not a valid Uint256") {
        uint256_check(token_id);
    }
    let (owner) = SBToken_owner.read(token_id);
    with_attr error_message("SBToken: owner query for nonexistent token") {
        assert_not_zero(owner);
    }
    return (owner=owner);
}
//
@view
func token_id_of{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    owner:felt
) -> (token_id: Uint256) {
    alloc_locals;
    let (token_id) = SBToken_tokenID.read(owner);
    return (token_id=token_id);
}

//
// Externals
//

@external
func mint{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    owner: felt, owner_name:felt, graduation_status : Uint256
) -> (token_id:Uint256) {
    alloc_locals;
    let (creator) = SBToken_creator.read();
    let (caller) = get_caller_address();
    with_attr error_message("Mint: caller must be the owner") {
        assert creator = caller;
    }

    let (mint_status) = Mint_status.read(owner);
    with_attr error_message("Mint: Already minted to this owner") {
        assert mint_status = Uint256(0,0);
    }
//TO DO CHECK EMITTED COUNT IS UINT
    let (emitted_count : Uint256) = get_emitted_count();
    let (token_id, _: Uint256) = uint256_add(emitted_count, Uint256(1, 0));
    _mint(owner, token_id, owner_name, graduation_status);

    Minted.emit(owner, token_id, owner_name, graduation_status);

    //let (emitted_count) = SafeUint256.add(token_id, Uint256(1, 0));
    SBToken_emitted_count.write(token_id);
    //return(token_id = token_id);
    return(token_id=token_id);


}

//To do function to change graduation status

// unequip
@external
func unequip{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
) -> (success: felt) {
    alloc_locals;
    let (caller) = get_caller_address();
    with_attr error_message("Unequip: caller is the zero address") {
        assert_not_zero(caller);
    }

    _burn(caller);
    return (success = TRUE);
}

@external
func remove_token{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(owner: felt
) -> (success: felt) {
    alloc_locals;
    let (creator) = SBToken_creator.read();
    let (caller) = get_caller_address();
    with_attr error_message("Remove_Token: caller is the zero address") {
        assert_not_zero(caller);
    }
    with_attr error_message("Remove_Token: caller must be the creator") {
        assert creator = caller;
    }
    _burn(owner);
    return (success = TRUE);
}


//
// Internals
//

func _mint{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    owner: felt, token_id: Uint256, owner_name:felt, graduation_status : Uint256
) -> () {
    alloc_locals;
    with_attr error_message("Mint: token_id is not a valid Uint256") {
        uint256_check(token_id);
    }
    with_attr error_message("Mint: cannot mint to the zero address") {
        assert_not_zero(owner);
    }

    Mint_status.write(owner, Uint256(1,0));
    SBToken_tokenID.write(owner, token_id);
    SBToken_owner.write(token_id, owner);
    SBToken_owner_name.write(token_id,owner_name);
    Graduation_status.write(token_id, graduation_status);
    
    return ();
}


func _burn{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(owner: felt) {
    alloc_locals;
    let (token_id) = SBToken_tokenID.read(owner);
    with_attr error_message("Burn: token_id is not a valid Uint256") {
        uint256_check(token_id);
    }
    with_attr error_message("Burn: token does not exist") {
        assert_uint256_lt(Uint256(0,0), token_id);
    }

    // Delete owner
    SBToken_tokenID.write(owner, Uint256(0,0));
    SBToken_owner.write(token_id, 0);
    SBToken_owner_name.write(token_id,0);
    Graduation_status.write(token_id, Uint256(0,0));
    return ();
}


func _exists{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    token_id: Uint256
) -> felt {
    alloc_locals;
    let (exists) = SBToken_owner.read(token_id);
    if (exists == FALSE) {
        return FALSE;
    }

    return TRUE;
}

