/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */
import { Signer, utils, Contract, ContractFactory, Overrides } from "ethers";
import type { Provider, TransactionRequest } from "@ethersproject/providers";
import type { PromiseOrValue } from "../../../common";
import type {
  NonAggressionPact,
  NonAggressionPactInterface,
} from "../../../contracts/treaties/NonAggressionPact";

const _abi = [
  {
    inputs: [
      {
        internalType: "address",
        name: "_diamond",
        type: "address",
      },
    ],
    stateMutability: "nonpayable",
    type: "constructor",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "_nationID",
        type: "uint256",
      },
    ],
    name: "addToWhitelist",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [],
    name: "admin",
    outputs: [
      {
        internalType: "contract AdminFacet",
        name: "",
        type: "address",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "_nationID",
        type: "uint256",
      },
      {
        internalType: "bytes",
        name: "_encodedParams",
        type: "bytes",
      },
    ],
    name: "approveBattle",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "_nationID",
        type: "uint256",
      },
      {
        internalType: "bytes",
        name: "_encodedParams",
        type: "bytes",
      },
    ],
    name: "approveClaimTile",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "_nationID",
        type: "uint256",
      },
      {
        internalType: "bytes",
        name: "_encodedParams",
        type: "bytes",
      },
    ],
    name: "approveDelegateGameFunction",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "_nationID",
        type: "uint256",
      },
      {
        internalType: "bytes",
        name: "_encodedParams",
        type: "bytes",
      },
    ],
    name: "approveDeployTreaty",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "_nationID",
        type: "uint256",
      },
      {
        internalType: "bytes",
        name: "_encodedParams",
        type: "bytes",
      },
    ],
    name: "approveDisbandArmy",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "_nationID",
        type: "uint256",
      },
      {
        internalType: "bytes",
        name: "_encodedParams",
        type: "bytes",
      },
    ],
    name: "approveDisownTile",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "_nationID",
        type: "uint256",
      },
      {
        internalType: "bytes",
        name: "_encodedParams",
        type: "bytes",
      },
    ],
    name: "approveEndGather",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "_nationID",
        type: "uint256",
      },
      {
        internalType: "bytes",
        name: "_encodedParams",
        type: "bytes",
      },
    ],
    name: "approveEndTroopProduction",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "_nationID",
        type: "uint256",
      },
      {
        internalType: "bytes",
        name: "_encodedParams",
        type: "bytes",
      },
    ],
    name: "approveHarvestResource",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "_nationID",
        type: "uint256",
      },
      {
        internalType: "bytes",
        name: "_encodedParams",
        type: "bytes",
      },
    ],
    name: "approveHarvestResourcesFromCapital",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "_nationID",
        type: "uint256",
      },
      {
        internalType: "bytes",
        name: "_encodedParams",
        type: "bytes",
      },
    ],
    name: "approveJoinTreaty",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "_nationID",
        type: "uint256",
      },
      {
        internalType: "bytes",
        name: "_encodedParams",
        type: "bytes",
      },
    ],
    name: "approveLeaveTreaty",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "_nationID",
        type: "uint256",
      },
      {
        internalType: "bytes",
        name: "_encodedParams",
        type: "bytes",
      },
    ],
    name: "approveMove",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "_nationID",
        type: "uint256",
      },
      {
        internalType: "bytes",
        name: "_encodedParams",
        type: "bytes",
      },
    ],
    name: "approveMoveCapital",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "_nationID",
        type: "uint256",
      },
      {
        internalType: "bytes",
        name: "_encodedParams",
        type: "bytes",
      },
    ],
    name: "approveOrganizeArmy",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "_nationID",
        type: "uint256",
      },
      {
        internalType: "bytes",
        name: "_encodedParams",
        type: "bytes",
      },
    ],
    name: "approveRecoverTile",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "_nationID",
        type: "uint256",
      },
      {
        internalType: "bytes",
        name: "_encodedParams",
        type: "bytes",
      },
    ],
    name: "approveStartGather",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "_nationID",
        type: "uint256",
      },
      {
        internalType: "bytes",
        name: "_encodedParams",
        type: "bytes",
      },
    ],
    name: "approveStartTroopProduction",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "_nationID",
        type: "uint256",
      },
      {
        internalType: "bytes",
        name: "_encodedParams",
        type: "bytes",
      },
    ],
    name: "approveTransfer",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "_nationID",
        type: "uint256",
      },
      {
        internalType: "bytes",
        name: "_encodedParams",
        type: "bytes",
      },
    ],
    name: "approveUnloadResources",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "_nationID",
        type: "uint256",
      },
      {
        internalType: "bytes",
        name: "_encodedParams",
        type: "bytes",
      },
    ],
    name: "approveUpgradeCapital",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "_nationID",
        type: "uint256",
      },
      {
        internalType: "bytes",
        name: "_encodedParams",
        type: "bytes",
      },
    ],
    name: "approveUpgradeResource",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "_nationID",
        type: "uint256",
      },
      {
        internalType: "bytes",
        name: "_encodedParams",
        type: "bytes",
      },
    ],
    name: "approveUpgradeTile",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "description",
    outputs: [
      {
        internalType: "string",
        name: "",
        type: "string",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "diamond",
    outputs: [
      {
        internalType: "address",
        name: "",
        type: "address",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "game",
    outputs: [
      {
        internalType: "contract GameFacet",
        name: "",
        type: "address",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "getter",
    outputs: [
      {
        internalType: "contract GetterFacet",
        name: "",
        type: "address",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "_nationID",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "_duration",
        type: "uint256",
      },
    ],
    name: "minimumStayCheck",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "name",
    outputs: [
      {
        internalType: "string",
        name: "",
        type: "string",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "_nationID",
        type: "uint256",
      },
    ],
    name: "removeFromWhitelist",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "_nationID",
        type: "uint256",
      },
    ],
    name: "removeMember",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "string",
        name: "_functionName",
        type: "string",
      },
      {
        internalType: "uint256",
        name: "_subjectID",
        type: "uint256",
      },
      {
        internalType: "bool",
        name: "_canCall",
        type: "bool",
      },
    ],
    name: "treatyDelegateGameFunction",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [],
    name: "treatyJoin",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [],
    name: "treatyLeave",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
];

const _bytecode =
  "0x60806040523480156200001157600080fd5b5060405162001d3738038062001d37833981016040819052620000349162000201565b806001600160a01b0381166200009e5760405162461bcd60e51b815260206004820152602560248201527f437572696f5472656174793a204469616d6f6e642061646472657373207265716044820152641d5a5c995960da1b606482015260840160405180910390fd5b600080546001600160a01b039092166001600160a01b031992831681179091556001805483168217905560028054831682179055600380549092161790556040805180820190915260138082527f4e6f6e2d41676772657373696f6e205061637400000000000000000000000000602090920191825262000122916004916200015b565b506040518060600160405280603b815260200162001cfc603b9139805162000153916005916020909101906200015b565b50506200026f565b828054620001699062000233565b90600052602060002090601f0160209004810192826200018d5760008555620001d8565b82601f10620001a857805160ff1916838001178555620001d8565b82800160010185558215620001d8579182015b82811115620001d8578251825591602001919060010190620001bb565b50620001e6929150620001ea565b5090565b5b80821115620001e65760008155600101620001eb565b6000602082840312156200021457600080fd5b81516001600160a01b03811681146200022c57600080fd5b9392505050565b600181811c908216806200024857607f821691505b6020821081036200026957634e487b7160e01b600052602260045260246000fd5b50919050565b611a7d806200027f6000396000f3fe608060405234801561001057600080fd5b506004361061025b5760003560e01c80636a2a2b4e11610145578063d553ed48116100bd578063f0b7db4e1161008c578063f2e1730b11610071578063f2e1730b14610260578063f851a4401461037a578063fa91f75e1461026057600080fd5b8063f0b7db4e14610354578063f2395dc31461036757600080fd5b8063d553ed4814610260578063e534ae5f14610260578063e75991fa14610260578063ec19ae801461026057600080fd5b8063a1a74aae11610114578063c009a6cb116100f9578063c009a6cb14610260578063c3fe3e2814610341578063cbb34e861461026057600080fd5b8063a1a74aae1461032e578063a83280bc1461026057600080fd5b80636a2a2b4e146102e85780637284e416146102fb578063993a04b7146103035780639bcecd0b1461026057600080fd5b80632b9b15ad116101d857806339ebfad4116101a75780634ad30a911161018c5780634ad30a91146102605780635f310b121461026057806360acfcc61461026057600080fd5b806339ebfad41461026057806347b958a6146102e057600080fd5b80632b9b15ad146102ba5780632d47fe27146102605780632efd6629146102cd578063374155161461026057600080fd5b80631c3571731161022f578063243086c411610214578063243086c41461026057806328f59b83146102b25780632b451c641461026057600080fd5b80631c357173146102605780631e15495c1461026057600080fd5b8062048f5a1461026057806304dc7c741461026057806306fdde031461028857806314f2c4351461029d575b600080fd5b61027361026e366004611722565b61038d565b60405190151581526020015b60405180910390f35b6102906103f7565b60405161027f91906117d9565b6102b06102ab3660046117f3565b610485565b005b6102b0610737565b6102736102c836600461180c565b61088c565b6102b06102db36600461183c565b610aa7565b6102b0610bed565b6102736102f6366004611722565b610dc6565b610290610f75565b600254610316906001600160a01b031681565b6040516001600160a01b03909116815260200161027f565b6102b061033c3660046117f3565b610f82565b600154610316906001600160a01b031681565b600054610316906001600160a01b031681565b6102b06103753660046117f3565b611246565b600354610316906001600160a01b031681565b600080546001600160a01b031633146103ed5760405162461bcd60e51b815260206004820152601f60248201527f437572696f5472656174793a204f6e6c792067616d652063616e2063616c6c0060448201526064015b60405180910390fd5b5060015b92915050565b60048054610404906118ab565b80601f0160208091040260200160405190810160405280929190818152602001828054610430906118ab565b801561047d5780601f106104525761010080835404028352916020019161047d565b820191906000526020600020905b81548152906001019060200180831161046057829003601f168201915b505050505081565b60025460405163b356003960e01b81523060048201526000916001600160a01b03169063b356003990602401602060405180830381865afa1580156104ce573d6000803e3d6000fd5b505050506040513d601f19601f820116820180604052508101906104f291906118e5565b6002546040516384d969bd60e01b815260206004820152600560248201526427bbb732b960d91b60448201529192506000916001600160a01b03909116906384d969bd90606401602060405180830381865afa158015610556573d6000803e3d6000fd5b505050506040513d601f19601f8201168201806040525081019061057a91906118fe565b6001600160a01b0316634c518fdc836040518263ffffffff1660e01b81526004016105a791815260200190565b600060405180830381865afa1580156105c4573d6000803e3d6000fd5b505050506040513d6000823e601f3d908101601f191682016040526105ec9190810190611927565b8060200190518101906105ff91906118e5565b60025460405163b356003960e01b81523360048201529192506001600160a01b03169063b356003990602401602060405180830381865afa158015610648573d6000803e3d6000fd5b505050506040513d601f19601f8201168201806040525081019061066c91906118e5565b81146106ba5760405162461bcd60e51b815260206004820181905260248201527f437572696f5472656174793a204f6e6c79206f776e65722063616e2063616c6c60448201526064016103e4565b6003546040517f37e9323a000000000000000000000000000000000000000000000000000000008152600481018590526001600160a01b03909116906337e9323a906024015b600060405180830381600087803b15801561071a57600080fd5b505af115801561072e573d6000803e3d6000fd5b50505050505050565b60025460405163b356003960e01b81523360048201526000916001600160a01b03169063b356003990602401602060405180830381865afa158015610780573d6000803e3d6000fd5b505050506040513d601f19601f820116820180604052508101906107a491906118e5565b90506107b181601e61088c565b6108235760405162461bcd60e51b815260206004820152602960248201527f4e41506163743a204d757374207374617920666f72206174206c65617374203360448201527f30207365636f6e6473000000000000000000000000000000000000000000000060648201526084016103e4565b6003546040516307c25c6f60e21b8152600481018390526001600160a01b0390911690631f0971bc90602401600060405180830381600087803b15801561086957600080fd5b505af115801561087d573d6000803e3d6000fd5b505050506108896114ac565b50565b60025460405163b356003960e01b815230600482015260009182916001600160a01b039091169063b356003990602401602060405180830381865afa1580156108d9573d6000803e3d6000fd5b505050506040513d601f19601f820116820180604052508101906108fd91906118e5565b6002546040516384d969bd60e01b815260206004820152600d60248201527f496e697454696d657374616d700000000000000000000000000000000000000060448201529192506000916001600160a01b03909116906384d969bd90606401602060405180830381865afa158015610979573d6000803e3d6000fd5b505050506040513d601f19601f8201168201806040525081019061099d91906118fe565b60025460405163344289d960e11b815260048101889052602481018590526001600160a01b0392831692634c518fdc92169063688513b290604401602060405180830381865afa1580156109f5573d6000803e3d6000fd5b505050506040513d601f19601f82011682018060405250810190610a1991906118e5565b6040518263ffffffff1660e01b8152600401610a3791815260200190565b600060405180830381865afa158015610a54573d6000803e3d6000fd5b505050506040513d6000823e601f3d908101601f19168201604052610a7c9190810190611927565b806020019051810190610a8f91906118e5565b9050610a9b848261199e565b42101595945050505050565b60025460405163b356003960e01b81523360048201526000916001600160a01b03169063b356003990602401602060405180830381865afa158015610af0573d6000803e3d6000fd5b505050506040513d601f19601f82011682018060405250810190610b1491906118e5565b60035460025460405163b356003960e01b81523060048201529293506001600160a01b039182169263def70047928592899291169063b356003990602401602060405180830381865afa158015610b6f573d6000803e3d6000fd5b505050506040513d601f19601f82011682018060405250810190610b9391906118e5565b87876040518663ffffffff1660e01b8152600401610bb59594939291906119c4565b600060405180830381600087803b158015610bcf57600080fd5b505af1158015610be3573d6000803e3d6000fd5b5050505050505050565b60025460405163b356003960e01b81523360048201526001600160a01b039091169063d4c8cfb190829063b356003990602401602060405180830381865afa158015610c3d573d6000803e3d6000fd5b505050506040513d601f19601f82011682018060405250810190610c6191906118e5565b60025460405163b356003960e01b81523060048201526001600160a01b039091169063b356003990602401602060405180830381865afa158015610ca9573d6000803e3d6000fd5b505050506040513d601f19601f82011682018060405250810190610ccd91906118e5565b6040517fffffffff0000000000000000000000000000000000000000000000000000000060e085901b16815260048101929092526024820152604401602060405180830381865afa158015610d26573d6000803e3d6000fd5b505050506040513d601f19601f82011682018060405250810190610d4a91906119fc565b610dbc5760405162461bcd60e51b815260206004820152602e60248201527f437572696f5472656174793a204f6e6c792077686974656c6973746564206e6160448201527f74696f6e732063616e2063616c6c00000000000000000000000000000000000060648201526084016103e4565b610dc461157b565b565b60008082806020019051810190610ddd9190611a19565b6002546040517ff27fe5da00000000000000000000000000000000000000000000000000000000815260048101839052919450600093506001600160a01b0316915063f27fe5da90602401602060405180830381865afa158015610e45573d6000803e3d6000fd5b505050506040513d601f19601f82011682018060405250810190610e6991906118e5565b60025460405163b356003960e01b81523060048201529192506000916001600160a01b039091169063b356003990602401602060405180830381865afa158015610eb7573d6000803e3d6000fd5b505050506040513d601f19601f82011682018060405250810190610edb91906118e5565b60025460405163344289d960e11b815260048101859052602481018390529192506001600160a01b03169063688513b290604401602060405180830381865afa158015610f2c573d6000803e3d6000fd5b505050506040513d601f19601f82011682018060405250810190610f5091906118e5565b15610f6157600093505050506103f1565b610f6b868661038d565b9695505050505050565b60058054610404906118ab565b60025460405163b356003960e01b81523060048201526000916001600160a01b03169063b356003990602401602060405180830381865afa158015610fcb573d6000803e3d6000fd5b505050506040513d601f19601f82011682018060405250810190610fef91906118e5565b6002546040516384d969bd60e01b815260206004820152600560248201526427bbb732b960d91b60448201529192506000916001600160a01b03909116906384d969bd90606401602060405180830381865afa158015611053573d6000803e3d6000fd5b505050506040513d601f19601f8201168201806040525081019061107791906118fe565b6001600160a01b0316634c518fdc836040518263ffffffff1660e01b81526004016110a491815260200190565b600060405180830381865afa1580156110c1573d6000803e3d6000fd5b505050506040513d6000823e601f3d908101601f191682016040526110e99190810190611927565b8060200190518101906110fc91906118e5565b60025460405163b356003960e01b81523360048201529192506001600160a01b03169063b356003990602401602060405180830381865afa158015611145573d6000803e3d6000fd5b505050506040513d601f19601f8201168201806040525081019061116991906118e5565b81146111b75760405162461bcd60e51b815260206004820181905260248201527f437572696f5472656174793a204f6e6c79206f776e65722063616e2063616c6c60448201526064016103e4565b6003546040516307c25c6f60e21b8152600481018590526001600160a01b0390911690631f0971bc90602401600060405180830381600087803b1580156111fd57600080fd5b505af1158015611211573d6000803e3d6000fd5b50506003546040516317ff785160e21b8152600481018790526001600160a01b039091169250635ffde1449150602401610700565b60025460405163b356003960e01b81523060048201526000916001600160a01b03169063b356003990602401602060405180830381865afa15801561128f573d6000803e3d6000fd5b505050506040513d601f19601f820116820180604052508101906112b391906118e5565b6002546040516384d969bd60e01b815260206004820152600560248201526427bbb732b960d91b60448201529192506000916001600160a01b03909116906384d969bd90606401602060405180830381865afa158015611317573d6000803e3d6000fd5b505050506040513d601f19601f8201168201806040525081019061133b91906118fe565b6001600160a01b0316634c518fdc836040518263ffffffff1660e01b815260040161136891815260200190565b600060405180830381865afa158015611385573d6000803e3d6000fd5b505050506040513d6000823e601f3d908101601f191682016040526113ad9190810190611927565b8060200190518101906113c091906118e5565b60025460405163b356003960e01b81523360048201529192506001600160a01b03169063b356003990602401602060405180830381865afa158015611409573d6000803e3d6000fd5b505050506040513d601f19601f8201168201806040525081019061142d91906118e5565b811461147b5760405162461bcd60e51b815260206004820181905260248201527f437572696f5472656174793a204f6e6c79206f776e65722063616e2063616c6c60448201526064016103e4565b6003546040516307c25c6f60e21b8152600481018590526001600160a01b0390911690631f0971bc90602401610700565b60025460405163b356003960e01b81523360048201526000916001600160a01b03169063b356003990602401602060405180830381865afa1580156114f5573d6000803e3d6000fd5b505050506040513d601f19601f8201168201806040525081019061151991906118e5565b6003546040516317ff785160e21b8152600481018390529192506001600160a01b031690635ffde14490602401600060405180830381600087803b15801561156057600080fd5b505af1158015611574573d6000803e3d6000fd5b5050505050565b60025460405163b356003960e01b81523360048201526000916001600160a01b03169063b356003990602401602060405180830381865afa1580156115c4573d6000803e3d6000fd5b505050506040513d601f19601f820116820180604052508101906115e891906118e5565b6003546040517fff2a5e79000000000000000000000000000000000000000000000000000000008152600481018390529192506001600160a01b03169063ff2a5e79906024016020604051808303816000875af115801561164d573d6000803e3d6000fd5b505050506040513d601f19601f8201168201806040525081019061167191906118e5565b5050565b634e487b7160e01b600052604160045260246000fd5b604051601f8201601f1916810167ffffffffffffffff811182821017156116b4576116b4611675565b604052919050565b600067ffffffffffffffff8211156116d6576116d6611675565b50601f01601f191660200190565b60006116f76116f2846116bc565b61168b565b905082815283838301111561170b57600080fd5b828260208301376000602084830101529392505050565b6000806040838503121561173557600080fd5b82359150602083013567ffffffffffffffff81111561175357600080fd5b8301601f8101851361176457600080fd5b611773858235602084016116e4565b9150509250929050565b60005b83811015611798578181015183820152602001611780565b838111156117a7576000848401525b50505050565b600081518084526117c581602086016020860161177d565b601f01601f19169290920160200192915050565b6020815260006117ec60208301846117ad565b9392505050565b60006020828403121561180557600080fd5b5035919050565b6000806040838503121561181f57600080fd5b50508035926020909101359150565b801515811461088957600080fd5b60008060006060848603121561185157600080fd5b833567ffffffffffffffff81111561186857600080fd5b8401601f8101861361187957600080fd5b611888868235602084016116e4565b9350506020840135915060408401356118a08161182e565b809150509250925092565b600181811c908216806118bf57607f821691505b6020821081036118df57634e487b7160e01b600052602260045260246000fd5b50919050565b6000602082840312156118f757600080fd5b5051919050565b60006020828403121561191057600080fd5b81516001600160a01b03811681146117ec57600080fd5b60006020828403121561193957600080fd5b815167ffffffffffffffff81111561195057600080fd5b8201601f8101841361196157600080fd5b805161196f6116f2826116bc565b81815285602083850101111561198457600080fd5b61199582602083016020860161177d565b95945050505050565b600082198211156119bf57634e487b7160e01b600052601160045260246000fd5b500190565b85815260a0602082015260006119dd60a08301876117ad565b6040830195909552506060810192909252151560809091015292915050565b600060208284031215611a0e57600080fd5b81516117ec8161182e565b600080600060608486031215611a2e57600080fd5b835192506020840151915060408401519050925092509256fea2646970667358221220bd0d780a2e45ccbd702fb0d20b302ea145452432c57cb14990ebcf568373e37a64736f6c634300080d00334d656d626572206e6174696f6e732063616e6e6f7420626174746c652061726d696573206f722074696c6573206f66206f6e6520616e6f74686572";

type NonAggressionPactConstructorParams =
  | [signer?: Signer]
  | ConstructorParameters<typeof ContractFactory>;

const isSuperArgs = (
  xs: NonAggressionPactConstructorParams
): xs is ConstructorParameters<typeof ContractFactory> => xs.length > 1;

export class NonAggressionPact__factory extends ContractFactory {
  constructor(...args: NonAggressionPactConstructorParams) {
    if (isSuperArgs(args)) {
      super(...args);
    } else {
      super(_abi, _bytecode, args[0]);
    }
  }

  override deploy(
    _diamond: PromiseOrValue<string>,
    overrides?: Overrides & { from?: PromiseOrValue<string> }
  ): Promise<NonAggressionPact> {
    return super.deploy(
      _diamond,
      overrides || {}
    ) as Promise<NonAggressionPact>;
  }
  override getDeployTransaction(
    _diamond: PromiseOrValue<string>,
    overrides?: Overrides & { from?: PromiseOrValue<string> }
  ): TransactionRequest {
    return super.getDeployTransaction(_diamond, overrides || {});
  }
  override attach(address: string): NonAggressionPact {
    return super.attach(address) as NonAggressionPact;
  }
  override connect(signer: Signer): NonAggressionPact__factory {
    return super.connect(signer) as NonAggressionPact__factory;
  }

  static readonly bytecode = _bytecode;
  static readonly abi = _abi;
  static createInterface(): NonAggressionPactInterface {
    return new utils.Interface(_abi) as NonAggressionPactInterface;
  }
  static connect(
    address: string,
    signerOrProvider: Signer | Provider
  ): NonAggressionPact {
    return new Contract(address, _abi, signerOrProvider) as NonAggressionPact;
  }
}
