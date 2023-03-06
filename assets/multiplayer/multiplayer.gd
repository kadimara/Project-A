# main.gd
extends Node2D

# If a mobile is on 4g it is probebly 4
var ip = IP.get_local_addresses()[5]

var port = 3333
var network = ENetMultiplayerPeer.new()

var isServer = false
var server = UDPServer.new()
var udp = PacketPeerUDP.new()
var networkId = null

var position_storage = Vector2()

# The player scene (which we want to configure for replication).
const PLAYER = preload("res://player/player.tscn")
@onready var players = get_tree().current_scene.get_node("Players")

var timer = Timer.new()

func _ready():
	udp.set_broadcast_enabled(true)
	udp.set_dest_address('255.255.255.255', 4242)
	init()

func init():
	udp.put_packet("Someone there!?".to_ascii_buffer())
	await get_tree().create_timer(0.5).timeout
	if udp.get_available_packet_count() > 0:
		var serverIp = udp.get_packet().get_string_from_ascii()
		client(serverIp)
	else:
		host()

func _process(delta):
	if not isServer:
		return
		
	server.poll()
	if not server.is_connection_available():
		return
		
	var peer: PacketPeerUDP = server.take_connection()
	var packet = peer.get_packet()
	# Reply so it knows the server ip
	peer.put_packet(ip.to_ascii_buffer())

func client(serverIp):
	# Client
	network.create_client(serverIp, port)
	multiplayer.multiplayer_peer = network
	multiplayer.server_disconnected.connect(server_disconnected)
	
	networkId = network.get_unique_id()
	set_label('client ' + str(networkId))

func host():
	server.listen(4242)
	isServer = true
		
	# Server
	network.create_server(port)
	multiplayer.multiplayer_peer = network
	multiplayer.peer_connected.connect(instance_player)
	multiplayer.peer_disconnected.connect(destroy_player)
	
	networkId = network.get_unique_id()
	set_label('server ' + str(networkId))
	instance_player(1)
	
func instance_player(id):
	var player = PLAYER.instantiate()
	player.name = str(id)
	players.add_child(player)

func destroy_player(id):
	var node = players.get_node(str(id))
	node.queue_free()

func server_disconnected():
	var lowestNetworkId = networkId
	for player in players.get_children():
		var id = player.name.to_int()
		if id != 1 && id < lowestNetworkId:
			lowestNetworkId = id
	
#	The player with the lowest network ID will host the new server.
	set_label('.........')
	if lowestNetworkId == networkId:
		init()
	else:
#		Wait and create a new connection
		await get_tree().create_timer(0.5).timeout
		init()

func set_label(text):
	var label = get_tree().current_scene.get_node('ServerOrHost')
	label.text = text
