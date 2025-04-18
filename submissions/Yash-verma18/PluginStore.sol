// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PluginStore {
    struct PlayerProfile {
        string name;
        string avatar;
    }

    mapping(address => PlayerProfile) public profile;
    mapping(string => address) public plugins;

    function setProfile(string memory _name, string memory _avatar) external {
        profile[msg.sender] = PlayerProfile(_name, _avatar);
    }

    function getProfile(
        address _player
    ) external view returns (string memory name, string memory avatar) {
        PlayerProfile memory playerProf = profile[_player];
        return (playerProf.name, playerProf.avatar);
    }

    function registerPlugin(string memory key, address pluginAddress) external {
        plugins[key] = pluginAddress;
    }

    function getPlugin(string memory _key) external view returns (address) {
        return plugins[_key];
    }

    function runPlugin(
        string memory key,
        string memory functionSignature,
        address user,
        string memory arguments
    ) external {
        address plugin = plugins[key];
        require(plugin != address(0), "No Plugin found");

        bytes memory data = abi.encodeWithSignature(
            functionSignature,
            user,
            arguments
        );
        (bool success, ) = plugin.call(data);
        require(success, "Plugin Function Call Failed");
    }

    function runPluginView(
        string memory key,
        string memory functionSignature,
        address user
    ) external view returns (string memory) {
        address plugin = plugins[key];
        require(plugin != address(0), "Plugin not registered");

        bytes memory data = abi.encodeWithSignature(functionSignature, user);
        (bool success, bytes memory result) = plugin.staticcall(data);
        require(success, "Plugin view call failed");

        return abi.decode(result, (string));
    }
}
