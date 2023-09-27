pragma solidity >0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

error No_Simple_Card_NFTs_To_Transfer();

contract SimpleCardNFTFactory is ERC721 {
    uint public tokenId;

    struct SimpleCardInfo {
        string name;
        string email;
        address issuer;
        string company;
        string university;
        string major;
        string phone;
        string portfolio;
    }

    mapping(address  => SimpleCardInfo ) private _infos;
    mapping(address => uint[]) private _tokenIdsMadeByIssuer;
    mapping(address => mapping(uint=> bool)) private _isTokenStillOwnedByIssuer;
    mapping(uint => address) private _issuerOfToken;
    mapping(address => uint) private _amountOfTokenOwnedByIssuer;

    event SimpleCardInfoRegistered(
        address indexed issuer,
        string name,
        string email,
        string company,
        string university,
        string major,
        string phone,
        string portfolio
    );

    event SimpleCardNFTMinted(
        uint indexed tokenId,
        address issuer,
        uint amountOfTokenOwnedByIssuer
    );

    event SimpleCardNFTTransfered(
        address indexed to,
        address from,
        uint tokenId,
        uint amountOfTokenOwnedByIssuer
    );

    modifier isSimpleCardInfoRegistered(){
        SimpleCardInfo memory mySimpleCardInfo = _infos[msg.sender];
        require(
            keccak256(abi.encodePacked(mySimpleCardInfo.name)) != keccak256(abi.encodePacked("")),
            "Register your Simple Card info First"
        );
        _;
    }

     constructor() ERC721("SimpleCardNFT", "SCard") {}

     function registerSimpleCardInfo (
        string memory _name, 
        string memory _email,
        string memory _company,
        string memory _university,
        string memory _major,
        string memory _phone,
        string memory _portfolio
     )public{
        SimpleCardInfo memory simpleCardInfo = SimpleCardInfo({
            name:_name,
            email:_email,
            issuer: msg.sender,
            company:_company,
            university:_university,
            major:_major,
            phone:_phone,
            portfolio:_portfolio
        });
               
        _infos[msg.sender] = simpleCardInfo;

        emit SimpleCardInfoRegistered(msg.sender, _name, _email, _company, _university, _major, _phone, _portfolio);
    } 

    function mintSimpleCardNFT () public payable
    isSimpleCardInfoRegistered {
        tokenId++;

        _mint(msg.sender, tokenId);

        uint[] storage tokenIdsMadeByIssuer = _tokenIdsMadeByIssuer[msg.sender];
        tokenIdsMadeByIssuer.push(tokenId);
        _isTokenStillOwnedByIssuer[msg.sender][tokenId] = true;
        _issuerOfToken[tokenId] = msg.sender;      
        _amountOfTokenOwnedByIssuer[msg.sender]++;

        emit SimpleCardNFTMinted(tokenId,msg.sender, _amountOfTokenOwnedByIssuer[msg.sender]);
    }

     function transferSimpleCardNFT (address to) public isSimpleCardInfoRegistered{
        require(_amountOfTokenOwnedByIssuer[msg.sender]!=0,"Mint your Simple Card NFT first");

        uint _tokenIdToTransfer;
        uint[] memory tokenIdsMadeByIssuer =_tokenIdsMadeByIssuer[msg.sender];
        for (uint i=0;i<tokenIdsMadeByIssuer.length;i++) {
            uint _tokenIdMadeByIssuer = tokenIdsMadeByIssuer[i];
            if (_isTokenStillOwnedByIssuer[msg.sender][_tokenIdMadeByIssuer]==true) {
                _tokenIdToTransfer = _tokenIdMadeByIssuer;
                break;
            }
            if ((i==tokenIdsMadeByIssuer.length-1)&&(_isTokenStillOwnedByIssuer[msg.sender][_tokenIdMadeByIssuer]==false)){
                revert No_Simple_Card_NFTs_To_Transfer();
            }
        }

        safeTransferFrom(msg.sender, to, _tokenIdToTransfer);

        _isTokenStillOwnedByIssuer[msg.sender][_tokenIdToTransfer]= false;
        _amountOfTokenOwnedByIssuer[msg.sender] --;

        emit SimpleCardNFTTransfered(to, msg.sender, _tokenIdToTransfer, _amountOfTokenOwnedByIssuer[msg.sender]);
    }

    function getSimpleCardInfo(address issuer) external view returns (SimpleCardInfo memory){
        return _infos[issuer];
    }

    function getAmountOfTokenOwnedByIssuer(address issuer) external view returns (uint){
        return _amountOfTokenOwnedByIssuer[issuer];
    }

}