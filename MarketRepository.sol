// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./ProductInstanceRepository.sol";

contract MarketRepository {

    // Array with all products
    Product[] public products;

    // Mapping from author to a list of product
    mapping(address => Product[]) public productAuthor;

    // Mapping from product index to a list of instance
    mapping(uint256 => ProductInstance[]) public productInstances;

    // Product struct which holds all the required info
    struct Product {
        uint productId;
        string name;
        uint256 shareProfit;
        uint256 defaultPrice;
        string metadata;
        address payable author;
    }

    struct ProductInstance {
        Product product;
        uint256 price;
        string metadata;
        uint256 instanceId;
        address repositoryAddress;
        address payable author;
    }

    /**
    * @dev Guarantees this contract is owner of the given productInstance/token
    * @param _productInstanceRepositoryAddress address of the productInstance repository to validate from
    * @param _productInstanceIds uint256 ID of the productInstance which has been registered in the productInstance repository
    */
    modifier contractIsProductInstanceOwner(address _productInstanceRepositoryAddress, uint256[] calldata _productInstanceIds) {
        for (uint256 i = 0; i < _productInstanceIds.length; i++) {
            address instanceOwner = ProductInstanceRepository(_productInstanceRepositoryAddress).ownerOf(_productInstanceIds[i]);
            require(instanceOwner == address(this));
        }
        _;
    }

    modifier buyerIsNotProductInstanceOwner(ProductInstance calldata _instance) {
        address instanceOwner = ProductInstanceRepository(_instance.repositoryAddress).ownerOf(_instance.instanceId);
        require(instanceOwner != address(msg.sender));
        _;
    }

    /**
    * @dev Creates an product with the given informatin
    * @param _productInstanceRepositoryAddress address of the ProductInstanceRepository contract
    * @param _productInstanceIds uint256 of the productInstance registered in ProductInstanceRepository
    * @param _productTitle string containing product title
    * @param _metadata string containing product metadata 
    * @param _price uint256 starting price of the product
    * @return bool whether the product is created
    */
    function createProduct(address _productInstanceRepositoryAddress, uint256[] calldata _productInstanceIds, 
        string memory _productTitle, string memory _metadata, uint256 _price) 
        public contractIsProductInstanceOwner(_productInstanceRepositoryAddress, _productInstanceIds) returns(bool) {
        uint productId = products.length;
        Product memory newProduct;
        newProduct.productId = productId;
        newProduct.name = _productTitle;
        newProduct.defaultPrice = _price;
        newProduct.metadata = _metadata;

        address payable receiver = payable(msg.sender);
        newProduct.author = receiver;
        
        productAuthor[msg.sender].push(newProduct);

        for (uint256 i = 0; i < _productInstanceIds.length; i++) {
            ProductInstance memory newInstance;
            newInstance.product = newProduct;
            newInstance.price = _price;
            newInstance.metadata = _metadata;
            newInstance.instanceId = _productInstanceIds[i];
            newInstance.repositoryAddress = _productInstanceRepositoryAddress;
            newInstance.author = receiver;
            productInstances[productId].push(newInstance);
        }
        
        emit ProductCreated(msg.sender, productId);
        return true;
    }

    function resellProduct(ProductInstance calldata _instance) public returns(bool isSuccess) {
         
        ProductInstanceRepository instanceRepository = ProductInstanceRepository(_instance.repositoryAddress);

        // Call the safeTransferFrom function to transfer ownership to this contract
        instanceRepository.safeTransferFrom(msg.sender, address(this), _instance.instanceId);

        // update price
        ProductInstance[] memory list = productInstances[_instance.product.productId];
        for(uint256 i = 0; i<list.length; i++) {
            ProductInstance memory instance = list[i];
            if (instance.instanceId == _instance.instanceId && instance.price != _instance.price) {
                // if price is changed, update price
                productInstances[_instance.product.productId][i].price = _instance.price;
            }
        }
        return true;
    }

    /**
    * @dev Buy a product instance. There should be payment para here. Skip for now
    * @param _instance a specific instance
    */
    function buyProduct(ProductInstance calldata _instance) public buyerIsNotProductInstanceOwner(_instance) returns(bool isSuccess) {

        // call paymaster
        bool isPaymentSuccess = true;
        require(isPaymentSuccess);

        // transfer ownership to buyer
        // Get an instance of the ERC721 contract
        ProductInstanceRepository instanceRepository = ProductInstanceRepository(_instance.repositoryAddress);

        // Call the safeTransferFrom function to transfer ownership to buyer
        instanceRepository.safeTransferFrom(address(this), msg.sender, _instance.instanceId);

        return true;      
    } 

    /**
    * @dev Gets an array of owned product
    * @param _author address of the product author
    */
    function getProductOf(address _author) public view returns(Product[] memory authOwnedProducts) {
        Product[] memory ownedProducts = productAuthor[_author];
        return ownedProducts;
    }

    /**
    * @dev Gets the instance list of a product
    * @param _productId product index
    */
    function getProductInstanceOf(uint _productId) public view returns(ProductInstance[] memory instances) {
        ProductInstance[] memory list = productInstances[_productId];
        return list;
    }

    /**
    * @dev Gets the on sale instance list of a product
    * @param _productId product index
    */
    function getOnSaleProductInstanceOf(uint _productId) public view returns(ProductInstance[] memory instances) {
        ProductInstance[] memory all = productInstances[_productId];
        // array in memory can not be dynamic 
        // allocating space in advanced is required. Do the caculation first.
        uint a = 0;
        for (uint256 i = 0; i < all.length; i++) {
            ProductInstance memory instance = all[i];
            // instance owned by contract is on sale.
            // It's possible that no instance exist
            address instanceOwner = ProductInstanceRepository(instance.repositoryAddress).ownerOf(instance.instanceId);
            bool isContractOwnThisInstance = instanceOwner == address(this);
            if (isContractOwnThisInstance) {
                a++;
            } 
        }

        ProductInstance[] memory list = new ProductInstance[](a);
        uint b = 0;
        for (uint256 i = 0; i < all.length; i++) {
            ProductInstance memory instance = all[i];
            address instanceOwner = ProductInstanceRepository(instance.repositoryAddress).ownerOf(instance.instanceId);
            bool isContractOwnThisInstance = instanceOwner == address(this);
            if (isContractOwnThisInstance) {
                list[b] = instance;
                b++;
            } 
        }
        return list;
    }

    event ProductCreated(address _owner, uint _productId);
}
