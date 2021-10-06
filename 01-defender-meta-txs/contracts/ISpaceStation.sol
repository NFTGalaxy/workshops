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

    SPDX-License-Identifier: Apache License, Version 2.0
*/
pragma solidity 0.8.0;

import {IStarNFT} from "./IStarNFT.sol"; 


/**
 * @title IStarNFT
 * @author Galaxy Protocol
 *
 * Interface for operating with StarNFTs.
 */
interface ISpaceStation {

    function claim(uint256 _cid, IStarNFT _starNFT, uint256 _dummyId, uint256 _powah, bytes calldata _signature) external; 

    function claimBatch(uint256 _cid, IStarNFT _starNFT, uint256[] calldata _dummyIdArr, uint256[] calldata _powahArr, bytes calldata _signature) external; 

    function forge(uint256 _cid, IStarNFT _starNFT, uint256[] calldata _nftIDs, uint256 _dummyId, uint256 _powah, bytes calldata _signature) external; 
}
