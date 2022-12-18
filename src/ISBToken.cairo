// SPDX-License-Identifier: MIT

%lang starknet

from starkware.cairo.common.uint256 import Uint256

@contract_interface
namespace ISBToken {

    func name() -> (name: felt) {
    }

    func symbol(owner : felt) -> (balance: Uint256) {
    }

    func get_emitted_count() -> (emitted_count: Uint256) {
    }

    func view_certificate(owner : felt) -> (token_id:Uint256, owner_name:felt, graduation_status : Uint256) {
    }

    func mint(owner: felt, owner_name:felt, graduation_status : Uint256) -> (token_id:Uint256) {
    }

    func unequip() -> (success: felt) {
    }

    func remove_token(owner: felt)-> (success: felt){
    }

    func owner_of(token_id:Uint256) -> (owner: felt) {
    }

    func token_id_of(owner: felt) -> (token_id:Uint256) {
    }

}
