// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;
pragma abicoder v2;

import "../TornadoInstanceCloneFactory.sol";
import "../tornado_proxy/TornadoProxy.sol";

contract Add3Instances {
  TornadoInstanceCloneFactory public immutable instanceFactory;
  address public immutable token;
  address public immutable proxyAddress;

  uint256 public immutable denomination1;
  uint256 public immutable denomination2;
  uint256 public immutable denomination3;

  event UpdatedInstanceForProxy(address instance, address token, uint256 denomination);

  constructor(
    address _proxyAddress,
    address _instanceFactory,
    uint256[3] memory _denominations,
    address _token
  ) {
    instanceFactory = TornadoInstanceCloneFactory(_instanceFactory);
    token = _token;
    proxyAddress = _proxyAddress;

    denomination1 = _denominations[0];
    denomination2 = _denominations[1];
    denomination3 = _denominations[2];
  }

  function executeProposal() external {
    TornadoProxy tornadoProxy = TornadoProxy(proxyAddress);

    for (uint256 i = 0; i < 3; i++) {
      ITornadoInstance instance = ITornadoInstance(instanceFactory.createInstanceClone(denominations(i), token));

      TornadoProxy.Instance memory newInstanceData = TornadoProxy.Instance(
        true,
        IERC20(token),
        TornadoProxy.InstanceState.ENABLED
      );

      TornadoProxy.Tornado memory tornadoForUpdate = TornadoProxy.Tornado(instance, newInstanceData);

      tornadoProxy.updateInstance(tornadoForUpdate);

      emit UpdatedInstanceForProxy(address(instance), instance.token(), instance.denomination());
    }
  }

  function denominations(uint256 index) private view returns (uint256) {
    if (index > 1) {
      return denomination3;
    } else if (index > 0) {
      return denomination2;
    } else {
      return denomination1;
    }
  }
}
