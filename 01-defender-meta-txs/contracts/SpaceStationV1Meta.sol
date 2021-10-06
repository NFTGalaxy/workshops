/*
    Copyright 2021 Project Galaxy.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

    SPDX-License-Identifier: Apache-2.0
*/

pragma solidity 0.8.0;

import {IStarNFT} from "./IStarNFT.sol"; 
import {ISpaceStation} from "./ISpaceStation.sol"; 
import {BaseRelayRecipient} from "openzeppelin-solidity/contracts/metatx/BaseRelayRecipient.sol";
import {MinimalForwarder} from "openzeppelin-solidity/contracts/metatx/MinimalForwarder.sol";
import {EIP712} from "openzeppelin-solidity/contracts/drafts/EIP712.sol";
import {ECDSA} from "openzeppelin-solidity/contracts/cryptography/ECDSA.sol";


/**
 * @title SpaceStation Gasless Proxy
 * @author Galaxy Protocol
 *
 * Campaign contract that allows privileged DAOs to initiate campaigns for members to claim StarNFTs.
 */
contract SpaceStationV1Meta is BaseRelayRecipient, EIP712 {

    address public galaxy_signer;
    address public manager;

    modifier onlyManager() {
        _validateOnlyManager();
        _;
    }


    constructor(address _trustedForwarder) 
	BaseRelayRecipient(_trustedForwarder)
        EIP712("Galaxy", "1.0.0")
    {
	manager = msg.sender;
    }


    function updateGalaxySigner(address newAddress) external onlyManager {
        require(newAddress != address(0), "Galaxy signer address must not be null address");                                                                                          
        galaxy_signer = newAddress;                                                                                                                                                   
    }


    // relayed functions
    function claim(ISpaceStation  _station, 
                   uint256        _cid, 
                   IStarNFT       _starNFT, 
                   uint256        _dummyId, 
                   uint256        _powah, 
                   bytes calldata _signature, 
                   bytes calldata _sig2) external payable {
        require(_verify(_hash(_cid, _starNFT, _dummyId, _powah, _msgSender()), _sig2), "Invalid signature");
	_station.claim(_cid, _starNFT, _dummyId, _powah, _signature);
        uint256 nftID = _starNFT.getNumMinted();
        _starNFT.safeTransferFrom(address(this), _msgSender(), nftID, 1, "");
    }


    function claimBatch(ISpaceStation      _station, 
                        uint256            _cid, 
                        IStarNFT           _starNFT, 
                        uint256[] calldata _dummyIdArr, 
                        uint256[] calldata _powahArr, 
                        bytes calldata     _signature,
                        bytes calldata     _sig2) external payable {
	require(_verify(_hashBatch(_cid, _starNFT, _dummyIdArr, _powahArr, _msgSender()), _sig2), "Invalid signature");
	_station.claimBatch(_cid, _starNFT, _dummyIdArr, _powahArr, _signature);
        uint256 numMinted = _starNFT.getNumMinted();
	uint256[] memory transferNfts = new uint256[](_powahArr.length);
	uint256[] memory values = new uint256[](_powahArr.length);
        uint256 j=0;
        for(uint256 i=numMinted-_powahArr.length; i<numMinted; i++) {
	    transferNfts[j] = i+1;
	    values[j] = 1;
            j++;
	}
	_starNFT.safeBatchTransferFrom(address(this), _msgSender(), transferNfts, values, "");
    }


    function forge(ISpaceStation _station, 
                   uint256 _cid, 
                   IStarNFT _starNFT, 
                   uint256[] calldata _nftIDs, 
                   uint256 _dummyId, 
                   uint256 _powah, 
                   bytes calldata _signature,
                   bytes calldata _sig2) external payable {
        require(_verify(_hashForge(_cid, _starNFT, _nftIDs, _dummyId, _powah, _msgSender()), _sig2), "Invalid signature");
        uint256[] memory values = new uint256[](_nftIDs.length);
        for (uint i = 0; i < _nftIDs.length; i++) {
            require(_starNFT.isOwnerOf(_msgSender(), _nftIDs[i]), "Not the owner");                                                                                                     
            values[i] = 1;
        }
	_starNFT.safeBatchTransferFrom(_msgSender(), address(this), _nftIDs, values, "");
	_station.forge(_cid, _starNFT, _nftIDs, _dummyId, _powah, _signature);
        uint256 nftID = _starNFT.getNumMinted();
        _starNFT.safeTransferFrom(address(this), _msgSender(), nftID, 1, "");
    }


    receive() external payable {
    }


    fallback() external payable {}


    // internal functions
    function _hash(uint256 _cid, IStarNFT _starNFT, uint256 _dummyId, uint256 _powah, address _account) public view returns (bytes32) {
        return _hashTypedDataV4(keccak256(abi.encode(
                keccak256("NFT(uint256 cid,address starNFT,uint256 dummyId,uint256 powah,address account)"),
                _cid, _starNFT, _dummyId, _powah, _account
            )));
    }


    function _hashBatch(uint256 _cid, IStarNFT _starNFT, uint256[] calldata _dummyIdArr, uint256[] calldata _powahArr, address _account) public view returns (bytes32) {
        return _hashTypedDataV4(keccak256(abi.encode(
                keccak256("NFT(uint256 cid,address starNFT,uint256[] dummyIdArr,uint256[] powahArr,address account)"),
                _cid, _starNFT, keccak256(abi.encodePacked(_dummyIdArr)), keccak256(abi.encodePacked(_powahArr)), _account
            )));
    }


    function _hashForge(uint256 _cid, IStarNFT _starNFT, uint256[] calldata _nftIDs, uint256 _dummyId, uint256 _powah, address _account) public view returns (bytes32) {
        return _hashTypedDataV4(keccak256(abi.encode(
                keccak256("NFT(uint256 cid,address starNFT,uint256[] nftIDs,uint256 dummyId,uint256 powah,address account)"),
                _cid, _starNFT, keccak256(abi.encodePacked(_nftIDs)), _dummyId, _powah, _account
            )));
    }


    function _verify(bytes32 hash, bytes calldata signature) public view returns (bool) {
        return ECDSA.recover(hash, signature) == galaxy_signer;
    }


    // can not be called by relayer
    function _validateOnlyManager() internal view {
        require(msg.sender == manager, "Only manager can call");
    }
}
