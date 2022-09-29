extends Node
signal ChangedNetState(from, to)
signal ConnectionStatus(evok)
signal PeerConnected
signal PeerJoined
signal PeerDesconnected(foced)

enum NetType {Offline, Server, Client} 
enum {
	ConnectionStatus_Connected # to server
	ConnectionStatus_Created # a server
	
	ConnectionStatus_Failed2Connect # to server
	ConnectionStatus_Failed2Create # a server
}

const VID = 0xff # byte
var _CheckedPeersVIDs : Array

const PORT_MAX = 65535
const PORT_MIN = 1024
const PORT_MIN_PRIVILAGE = 0

const RPCPort_Default = 31400
var RPCPort : int = 31400
const MaxPlayers = 8
const TestingIP = "127.0.0.1"
const OfflineTesting = true

var MasterId : int = 0
var isHost = false
var PeerIDs : Array = []
var Online : bool = false

var DeviceAdress : String
var BlackList : Array
var BlackListReversed : bool = false

var DetentedPeer : Dictionary # Peer:EndDetentionTime

func _ready() -> void:
	DeviceAdress = IP.get_local_addresses()[5]

func InitinalizeServer(ip : String = "*"):
	isHost = true
	if OfflineTesting:
		RPCPort = RPCPort_Default
	var peer = NetworkedMultiplayerENet.new()
	peer.encode_buffer_max_size = 67108864
	peer.create_server(RPCPort + VID, MaxPlayers)
	peer.allow_object_decoding = false
	get_tree().network_peer = peer
	get_tree().connect("network_peer_connected", self, "PeerConnected")
	get_tree().connect("network_peer_disconnected", self, "PeerDisconnected")
	if !Online:
		emit_signal("ChangedNetState", NetType.Offline, NetType.Server)
	else:
		emit_signal("ChangedNetState", NetType.Client, NetType.Server)
	Online = true
	UpdateIds()
	emit_signal("ConnectionStatus", ConnectionStatus_Created)

func InitinalizeClient(serverIp : String):
	isHost = false
	if OfflineTesting:
		serverIp = TestingIP
		RPCPort = RPCPort_Default
	var peer = NetworkedMultiplayerENet.new()
	peer.encode_buffer_max_size = 67108864
	peer.create_client(serverIp, RPCPort + VID)
	peer.allow_object_decoding = true
	get_tree().network_peer = peer
	peer.connect("server_disconnected", self, "serverQuited")
	peer.connect("connection_succeeded", self, "serverEntered")
	peer.connect("connection_failed", self, "ConnectionFailed")
	get_tree().connect("connected_to_server", self, "serverEntered")

func ConnectionFailed() -> void:
	emit_signal("ChangedNetState", NetType.Offline, NetType.Offline)
	emit_signal("ConnectionStatus", ConnectionStatus_Failed2Connect)
	UpdateIds()

func serverQuited() -> void:
	Online = false
	emit_signal("ChangedNetState", NetType.Client, NetType.Offline)
	UpdateIds()

func serverEntered() -> void:
	Online = true
	UpdateIds()
	emit_signal("ChangedNetState", NetType.Offline, NetType.Client)
	emit_signal("ConnectionStatus", ConnectionStatus_Connected)

func CloseConnection() -> void:
	if !Online: return
	if isHost:
		UpdateIds()
		(get_tree().network_peer as NetworkedMultiplayerENet).close_connection(1000)
		emit_signal("ChangedNetState", NetType.Server, NetType.Offline)
		Online = false
		return
	UpdateIds()
	(get_tree().network_peer as NetworkedMultiplayerENet).close_connection(50)
	serverQuited()

func PeerConnected(peer : int) -> void:
	emit_signal("PeerConnected", peer)
	UpdateIds()
	var flag = peer in BlackList
	if BlackListReversed:
		if !flag:
			KickPeer(peer)
			return
	else:
		if flag:
			KickPeer(peer)
			return
	
	if peer in DetentedPeer:
		var num0 : float = Time.get_unix_time_from_system()
		if num0 < DetentedPeer[peer]:
			KickPeer(peer)
			return
	
	emit_signal("PeerJoined")
	return # <<<<
	
#	yield(get_tree().create_timer(2.0, false), "timeout")
#	if !peer in _CheckedPeersVIDs:
#		KickPeer(peer)
#		return
#	else:
#		_CheckedPeersVIDs.erase(peer)

func _VaildatePeer(peer : int, vid : int) -> void:
	if vid == VID and !peer in _CheckedPeersVIDs:
		_CheckedPeersVIDs.append(peer)

func PeerDisconnected(peer : int):
	UpdateIds()
	emit_signal("PeerDesconnected", false, peer)

func KickPeer(peer : int) -> void:
	UpdateIds()
	if Online: get_tree().network_peer.disconnect_peer(peer, false)
	emit_signal("PeerDesconnected", true, peer)

func UpdateIds() -> void:
	MasterId = get_tree().get_network_unique_id()
	PeerIDs = get_tree().get_network_connected_peers()


