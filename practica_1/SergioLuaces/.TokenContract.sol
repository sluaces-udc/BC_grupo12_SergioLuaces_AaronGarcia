// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.30;

contract TokenContract {

    address public owner;

    struct Receivers {
        string name;
        uint256 tokens;
    }

    mapping(address => Receivers) public users;

    modifier onlyOwner(){
        require(msg.sender == owner, "Solo el propietario puede ejecutar esta funcion");
        _;
    }

    constructor(){
        owner = msg.sender;
        users[owner].tokens = 100;
    }

    // ----------------------------
    // Función auxiliar
    // ----------------------------
    function double(uint _value) public pure returns (uint){
        return _value * 2;
    }

    // ----------------------------
    // Registro de usuario
    // ----------------------------
    function register(string memory _name) public {
        users[msg.sender].name = _name;
    }

    // ----------------------------
    // Transferencia de tokens (solo owner)
    // ----------------------------
    function giveToken(address _receiver, uint256 _amount) public onlyOwner {
        require(users[owner].tokens >= _amount, "No hay suficientes tokens del propietario");
        users[owner].tokens -= _amount;
        users[_receiver].tokens += _amount;
    }

    // ----------------------------
    // Compra de tokens con Ether
    // ----------------------------
    function buyToken() public payable {
        uint256 tokenPrice = 5 ether;  // 1 token = 5 Ether
        require(msg.value >= tokenPrice, "Debes enviar al menos 5 Ether para comprar un token");

        uint256 tokensToBuy = msg.value / tokenPrice; // cantidad entera de tokens a comprar

        // Verificamos que el propietario tenga suficientes tokens
        require(users[owner].tokens >= tokensToBuy, "El propietario no tiene suficientes tokens");

        // Transferimos los tokens
        users[owner].tokens -= tokensToBuy;
        users[msg.sender].tokens += tokensToBuy;
    }

    // ----------------------------
    // Mostrar balance en Ether del contrato
    // ----------------------------
    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    // ----------------------------
    // Permitir al owner retirar el Ether acumulado
    // ----------------------------
    function withdraw() public onlyOwner {
        payable(owner).transfer(address(this).balance);
    }
}
