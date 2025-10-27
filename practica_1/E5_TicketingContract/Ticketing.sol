// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/// @title Ticketing para conciertos (struct personalizado, sin reventa)
/// @notice Emite, consulta y verifica entradas en cadena. No permite transferencias.
contract Ticketing {
    // -------------------------
    // Datos
    // -------------------------
    struct Ticket {
        uint256 id;         // ID único del ticket
        address owner;      // Propietario actual (comprador)
        string eventName;   // Nombre/identificador del evento
        bool isValid;       // true si no se ha usado/invalidado
    }

    address public organizer;                               // Organizador (admin del contrato)
    uint256 private _nextTicketId = 1;                      // Contador de IDs (empieza en 1)
    mapping(uint256 => Ticket) private _tickets;            // id => Ticket
    mapping(address => uint256[]) private _ticketsByOwner; // dueño => lista de IDs

    // -------------------------
    // Eventos
    // -------------------------
    event TicketIssued(uint256 indexed id, address indexed to, string eventName);
    event TicketValidated(uint256 indexed id, address indexed by);
    event TicketInvalidated(uint256 indexed id, address indexed by);

    // -------------------------
    // Errores personalizados (gas-eficientes)
    // -------------------------
    error NotOrganizer();
    error TicketDoesNotExist(uint256 id);
    error TicketAlreadyUsedOrInvalid(uint256 id);
    error ZeroAddress();

    // -------------------------
    // Modificadores
    // -------------------------
    modifier onlyOrganizer() {
        if (msg.sender != organizer) revert NotOrganizer();
        _;
    }

    // -------------------------
    // Constructor
    // -------------------------
    constructor() {
        organizer = msg.sender;
    }

    // -------------------------
    // Emisión (solo organizador)
    // -------------------------
    /// @notice Emite un ticket para `_to` del evento `_eventName`.
    /// @return id ID del ticket emitido.
    function issueTicket(address _to, string calldata _eventName)
        external
        onlyOrganizer
        returns (uint256 id)
    {
        if (_to == address(0)) revert ZeroAddress();

        id = _nextTicketId++;
        _tickets[id] = Ticket({
            id: id,
            owner: _to,
            eventName: _eventName,
            isValid: true
        });
        _ticketsByOwner[_to].push(id);

        emit TicketIssued(id, _to, _eventName);
    }

    // -------------------------
    // Verificación / uso (solo organizador)
    // -------------------------
    /// @notice Marca el ticket `id` como usado (invalida el acceso futuro).
    function verifyTicket(uint256 id) external onlyOrganizer {
        Ticket storage t = _tickets[id];
        if (t.owner == address(0)) revert TicketDoesNotExist(id);
        if (!t.isValid) revert TicketAlreadyUsedOrInvalid(id);

        t.isValid = false; // usado/inválido
        emit TicketValidated(id, msg.sender);
    }

    /// @notice Invalida un ticket sin usar (por ejemplo, reembolso/cancelación).
    function invalidateTicket(uint256 id) external onlyOrganizer {
        Ticket storage t = _tickets[id];
        if (t.owner == address(0)) revert TicketDoesNotExist(id);
        if (!t.isValid) revert TicketAlreadyUsedOrInvalid(id);

        t.isValid = false;
        emit TicketInvalidated(id, msg.sender);
    }

    // -------------------------
    // Consultas (lectura)
    // -------------------------
    /// @notice Devuelve los datos completos de un ticket.
    function getTicket(uint256 id)
        external
        view
        returns (uint256, address, string memory, bool)
    {
        Ticket storage t = _tickets[id];
        if (t.owner == address(0)) revert TicketDoesNotExist(id);
        return (t.id, t.owner, t.eventName, t.isValid);
    }

    /// @notice Dueño del ticket `id`.
    function ownerOf(uint256 id) external view returns (address) {
        Ticket storage t = _tickets[id];
        if (t.owner == address(0)) revert TicketDoesNotExist(id);
        return t.owner;
    }

    /// @notice Estado de validez del ticket `id` (true = válido).
    function isValid(uint256 id) external view returns (bool) {
        Ticket storage t = _tickets[id];
        if (t.owner == address(0)) revert TicketDoesNotExist(id);
        return t.isValid;
    }

    /// @notice Lista de IDs de tickets válidos del `user`.
    /// @dev O(n) en tickets emitidos a ese usuario. Útil para prototipo/Remix.
    function ticketsOf(address user) external view returns (uint256[] memory) {
        return _ticketsByOwner[user];
    }

    /// @notice Comprueba si `user` es el propietario actual del ticket `id`.
    function isOwnerOf(uint256 id, address user) external view returns (bool) {
        Ticket storage t = _tickets[id];
        if (t.owner == address(0)) revert TicketDoesNotExist(id);
        return t.owner == user;
    }

    // -------------------------
    // Notas:
    // - No hay función de transferencia: los tickets NO son revendibles en esta versión.
    // - En una evolución futura, podría añadirse reventa controlada, precio, pago en Ether, etc.
    // -------------------------
}
