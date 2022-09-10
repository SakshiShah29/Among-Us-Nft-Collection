//SPDX-License-Identifier:MIT

pragma solidity ^0.8.4;
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IWhitelist.sol";

contract AmongUs is ERC721Enumerable,Ownable{
    /**
     * @dev _baseTokenURI for computing (tokenuri),if set, the resulting
     * uri for each token will be the concatenation of the `baseURI` and the `tokenId`.
     */

    string _baseTokenURI;

    //_price is the price of one Among us nft
    uint256 public _price=0.01 ether;

    //_pause is too pause the contract in case of an emergency
    bool public _paused;

    //max number of amongUs Nfts
    uint256 public maxTokenIds=20;

    //total no. of tokenId minted
    uint256 public tokenIds;

    //Whitelist contract instance;
    IWhitelist whitelist;

    //boolean to keep track of whether the presale started or not
    bool public presaleStarted;

    //timestamp for when the presale would end
    uint256 public presaleEnded;

    modifier onlyWhenNotPaused {
        require(!_paused,"Contract currently paused");
        _;

    }

   //ERC721 takes in a `name` and a `symbol` to  the token collection,
   //name in our case is "AmongUs" and symbol is "AU"
   //contructor takes the baseURI to set _basetokenURI
   //it also initializes an instance of whitelist interface

   constructor (string memory baseURI,address whitelistContract) ERC721("Among Us","AU"){
    _baseTokenURI=baseURI;
    whitelist=IWhitelist(whitelistContract);
   }

   //startPresale starts the presale for whitelisted addresses
   function startPresale() public onlyOwner{
    presaleStarted=true;
    //Set presaleEnded time as current timestamp +5 mins
    presaleEnded=block.timestamp+5 minutes;

   }

   //presaleMint alows the user to mint one nft per transaction during the presale
   function presaleMint() public payable onlyWhenNotPaused{
    require(presaleStarted&&block.timestamp<presaleEnded,"Presale is not running!");
    require(whitelist.whitelistedAddresses(msg.sender),"You are not whitelisted!");
    require(tokenIds<maxTokenIds,"Exceeded maximum among us nfts supply!");
    require(msg.value>=_price,"Ether sent is not correct");
    tokenIds+=1;
    //safeMint is a safer version of the _mint function as it ensures that 
    //if the address being minted to is contract, then it knows how to deal with ERC721
    //if the address being minted to is not a contract, it works the same way as the _mint
    _safeMint(msg.sender,tokenIds);
   }

   //mint allows the user to mint one nft per transaction after the presale has ended
   function mint() public payable onlyWhenNotPaused{
    require(presaleStarted && block.timestamp>=presaleEnded,"Presale has not ended yet");
    require(tokenIds<maxTokenIds,"Exceeded max Among us Nfts supply");
    require(msg.value>=_price,"Ether sent is not correct");
    tokenIds+=1;
    _safeMint(msg.sender,tokenIds);
   }

   //baseURI overrides the openzepplins ERC721 implementations which by default
   //returned and empty string for the baseUri
   function _baseURI() internal view virtual override returns(string memory){
    return _baseTokenURI;
   }

   //setPased make the contract paused or unpaused
   function setPaused(bool val) public onlyOwner{
    _paused=val;
   }

   //withdraw sends all the ether in the contract to the owner of the contract
   function withdraw() public onlyOwner{
    address _owner=owner();
    uint256 amount =address(this).balance;
    (bool sent, )=_owner.call{value:amount}("");
    require(sent,"Failed to send the Ethers");
   }

   //funnction to recieve the Ether. msg.data must be empty
     receive() external payable {}

   //fallback function called when msg.data is not empty
   fallback() external payable{}

} 