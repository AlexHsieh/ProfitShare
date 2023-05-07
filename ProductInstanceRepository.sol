// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title Repository of ERC721 Instances
 * This contract contains the list of product instance registered by users.
 */
contract ProductInstanceRepository is ERC721, Ownable {

    // Mapping from token ID to uri
    mapping(uint256 => string) private tokenURIs;

    /**
    * @dev Created a InstanceRepository with a name and symbol
    * @param _name string represents the name of the repository
    * @param _symbol string represents the symbol of the repository
    */
    constructor(string memory _name, string memory _symbol) 
        ERC721(_name, _symbol) {}
    
    /**
    * @dev Public function to register a new product instance
    * @dev Call the ERC721Token minter
    * @param _tokenId uint256 represents a specific instance
    * @param _uri string containing metadata/uri
    */
    function registerInstance(uint256 _tokenId, string memory _uri) public onlyOwner {
        _safeMint(msg.sender, _tokenId);
        addInstanceMetadata(_tokenId, _uri);
        emit InstanceRegistered(msg.sender, _tokenId);
    }

    /**
    * @dev Public function to add metadata to a instance
    * @param _tokenId represents a specific instance
    * @param _uri text which describes the characteristics of a given instance
    * @return whether the instance metadata was added to the repository
    */
    function addInstanceMetadata(uint256 _tokenId, string memory _uri) public returns(bool){
        _setTokenURI(_tokenId, _uri);
        return true;
    }

     /**
    * @dev Internal function to set the token URI for a given token
    * @dev Reverts if the token ID does not exist
    * @param _tokenId uint256 ID of the token to set its URI
    * @param _uri string URI to assign
    */
    function _setTokenURI(uint256 _tokenId, string memory _uri) internal {
        require(_exists(_tokenId));
        tokenURIs[_tokenId] = _uri;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        _requireMinted(tokenId);

        return tokenURIs[tokenId];
    }

    /**
    * @dev Event is triggered if instance/token is registered
    * @param _by address of the registrar
    * @param _tokenId uint256 represents a specific instance
    */
    event InstanceRegistered(address _by, uint256 _tokenId);
}
