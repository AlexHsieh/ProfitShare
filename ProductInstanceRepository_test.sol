// SPDX-License-Identifier: GPL-3.0
        
pragma solidity >=0.4.22 <0.9.0;

// This import is automatically injected by Remix
import "remix_tests.sol"; 

// This import is required to use custom transaction context
// Although it may fail compilation in 'Solidity Compiler' plugin
// But it will work fine in 'Solidity Unit Testing' plugin
import "remix_accounts.sol";
import "./ProductInstanceRepository.sol";

// File name has to end with '_test.sol', this file can contain more than one testSuite contracts
contract testSuite {

    ProductInstanceRepository public repo;

    /// 'beforeAll' runs before all other tests
    /// More special functions are: 'beforeEach', 'beforeAll', 'afterEach' & 'afterAll'
    function beforeAll() public {
        repo = new ProductInstanceRepository("A Book", "USD");
    }

    function checkAddInstance() public {
        string memory bookuri = "http://abook.storage.somewhere/location1";
        repo.registerInstance(1, bookuri);
        string memory uri = repo.tokenURI(1);
        Assert.equal(uri, bookuri, "Incorrect book uri");
        string memory newBookuri = "http://abook.storage.amazon/location1";
        repo.addInstanceMetadata(1, newBookuri);
        Assert.equal(newBookuri, repo.tokenURI(1), "Incorrect book uri");
        Assert.equal("", repo.tokenURI(2), "Should be empty book uri");
        // Use 'Assert' methods: https://remix-ide.readthedocs.io/en/latest/assert_library.html
        // Assert.ok(2 == 2, 'should be true');
        // Assert.greaterThan(uint(2), uint(1), "2 should be greater than to 1");
        // Assert.lesserThan(uint(2), uint(3), "2 should be lesser than to 3");
    }

    /// Custom Transaction Context: https://remix-ide.readthedocs.io/en/latest/unittesting.html#customization
    /// #sender: account-1
    /// #value: 100
    // function checkSenderAndValue() public payable {
    //     // account index varies 0-9, value is in wei
    //     Assert.equal(msg.sender, TestsAccounts.getAccount(1), "Invalid sender");
    //     Assert.equal(msg.value, 100, "Invalid value");
    // }

    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }
}
    