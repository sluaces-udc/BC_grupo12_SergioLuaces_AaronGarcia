// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.30;

/// @title Contrato de tokens sencillo con compra mediante Ether
/// @notice Permite registrar usuarios, transferir tokens por el propietario
///         y comprar tokens enviando múltiplos de 5 ETH.
contract TokenContract {
    // Dirección del propietario (quien despliega el contrato)
    address public owner;

    // Estructura que guarda nombre y cantidad de tokens de cada usuario
    struct Receptor {
        string nombre;
        uint256 tokens;
    }

    // Relación de direcciones con su información asociada
    mapping(address => Receptor) public usuarios;

    // Precio fijo de cada token: 5 ETH
    uint256 public constant PRECIO = 5 ether;

    // -----------------------------
    // Modificadores y eventos
    // -----------------------------

    // Restringe funciones solo al propietario
    modifier soloPropietario() {
        require(msg.sender == owner, "No autorizado (solo propietario)");
        _;
    }

    // Eventos para registrar operaciones importantes en la blockchain
    event Compra(address indexed comprador, uint256 tokens, uint256 pagoWei);
    event Retirada(address indexed destino, uint256 cantidadWei);

    // -----------------------------
    // Constructor
    // -----------------------------
    constructor() {
        owner = msg.sender;
        usuarios[owner].tokens = 100; // stock inicial de tokens del propietario
    }

    // -----------------------------
    // Funciones principales
    // -----------------------------

    /// @notice Registra un nuevo usuario con un nombre identificativo
    function registrar(string memory _nombre) public {
        usuarios[msg.sender].nombre = _nombre;
    }

    /// @notice Permite al propietario regalar o transferir tokens a otro usuario
    function entregarToken(address _destino, uint256 _cantidad) public soloPropietario {
        require(usuarios[owner].tokens >= _cantidad, "No hay tokens suficientes");
        usuarios[owner].tokens -= _cantidad;
        usuarios[_destino].tokens += _cantidad;
    }

    /// @notice Acepta pagos directos al contrato (sin datos adicionales)
    receive() external payable {}

    /// @notice Permite comprar tokens enviando Ether (5 ETH por token)
    function comprarTokens() external payable {
        require(msg.value >= PRECIO, "Debes enviar al menos 5 ETH");
        require(msg.value % PRECIO == 0, "Debe ser multiplo exacto de 5 ETH");

        uint256 tokensComprados = msg.value / PRECIO;
        require(usuarios[owner].tokens >= tokensComprados, "No queda stock disponible");

        usuarios[owner].tokens -= tokensComprados;
        usuarios[msg.sender].tokens += tokensComprados;

        emit Compra(msg.sender, tokensComprados, msg.value);
    }

    /// @notice Consulta el saldo total en Ether que posee el contrato
    function saldoContratoWei() external view returns (uint256) {
        return address(this).balance;
    }

    /// @notice Permite al propietario retirar Ether del contrato
    /// @param destino Dirección a la que se enviarán los fondos
    /// @param cantidadWei Monto a retirar expresado en wei
    function retirar(address payable destino, uint256 cantidadWei) external soloPropietario {
        require(cantidadWei <= address(this).balance, "Saldo insuficiente");
        destino.transfer(cantidadWei);
        emit Retirada(destino, cantidadWei);
    }
}
