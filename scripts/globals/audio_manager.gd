extends Node

const BGMTEST_2 = preload("uid://cv64tcjdesmm4")
const BUTTONCLICK = preload("uid://boabkbngwys2p")
const COINCOLLECTSFX = preload("uid://8vecfu0w3ac0")
const DEADOOMPAS = preload("uid://rtw1h4ba6w3m")
const JUMPV_1 = preload("uid://giyb1xory4ig")
const SLINGSHOT = preload("uid://cmp2g5d0jrsxi")

const SETTINGS_PATH := "user://settings.cfg"
const SETTINGS_SECTION_AUDIO := "audio"
const SETTINGS_KEY_MASTER := "master"
const SETTINGS_KEY_BGM := "bgm"
const SETTINGS_KEY_SFX := "sfx"

const BUS_MASTER := "Master"
const BUS_BGM := "BGM"
const BUS_SFX := "SFX"

const DEFAULT_MASTER_LINEAR := 1.0
const DEFAULT_BGM_LINEAR := 1.0
const DEFAULT_SFX_LINEAR := 1.0

var bgm_streams: Array[AudioStreamPlayer]


func _ready() -> void:
	load_audio_settings()


func set_master_volume_linear(value: float) -> void:
	_set_bus_volume_linear(BUS_MASTER, value)


func set_bgm_volume_linear(value: float) -> void:
	_set_bus_volume_linear(BUS_BGM, value)


func set_sfx_volume_linear(value: float) -> void:
	_set_bus_volume_linear(BUS_SFX, value)


func get_master_volume_linear() -> float:
	return _get_bus_volume_linear(BUS_MASTER, DEFAULT_MASTER_LINEAR)


func get_bgm_volume_linear() -> float:
	return _get_bus_volume_linear(BUS_BGM, DEFAULT_BGM_LINEAR)


func get_sfx_volume_linear() -> float:
	return _get_bus_volume_linear(BUS_SFX, DEFAULT_SFX_LINEAR)


func save_audio_settings() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value(SETTINGS_SECTION_AUDIO, SETTINGS_KEY_MASTER, get_master_volume_linear())
	cfg.set_value(SETTINGS_SECTION_AUDIO, SETTINGS_KEY_BGM, get_bgm_volume_linear())
	cfg.set_value(SETTINGS_SECTION_AUDIO, SETTINGS_KEY_SFX, get_sfx_volume_linear())
	cfg.save(SETTINGS_PATH)


func load_audio_settings() -> void:
	var cfg := ConfigFile.new()
	var err := cfg.load(SETTINGS_PATH)
	if err != OK:
		set_master_volume_linear(DEFAULT_MASTER_LINEAR)
		set_bgm_volume_linear(DEFAULT_BGM_LINEAR)
		set_sfx_volume_linear(DEFAULT_SFX_LINEAR)
		save_audio_settings()
		return

	set_master_volume_linear(float(cfg.get_value(SETTINGS_SECTION_AUDIO, SETTINGS_KEY_MASTER, DEFAULT_MASTER_LINEAR)))
	set_bgm_volume_linear(float(cfg.get_value(SETTINGS_SECTION_AUDIO, SETTINGS_KEY_BGM, DEFAULT_BGM_LINEAR)))
	set_sfx_volume_linear(float(cfg.get_value(SETTINGS_SECTION_AUDIO, SETTINGS_KEY_SFX, DEFAULT_SFX_LINEAR)))


func _set_bus_volume_linear(bus_name: String, value: float) -> void:
	var bus_idx := AudioServer.get_bus_index(bus_name)
	if bus_idx == -1:
		return

	var linear := clampf(value, 0.0, 1.0)
	AudioServer.set_bus_volume_db(bus_idx, linear_to_db(linear))


func _get_bus_volume_linear(bus_name: String, fallback: float) -> float:
	var bus_idx := AudioServer.get_bus_index(bus_name)
	if bus_idx == -1:
		return fallback

	var db := AudioServer.get_bus_volume_db(bus_idx)
	return clampf(db_to_linear(db), 0.0, 1.0)


func play_sfx(sfx: AudioStream, pitch_scale: float = 1.0, volume: float = 1.0) -> void:
	if sfx == null:
		push_error("Unable to play sfx:",sfx)
		return
	
	var stream_player: AudioStreamPlayer = AudioStreamPlayer.new()
	var sfx_bus_idx = AudioServer.get_bus_index("SFX")
	var sfx_bus = AudioServer.get_bus_name(sfx_bus_idx)
	
	stream_player.bus = sfx_bus
	stream_player.stream = sfx
	stream_player.pitch_scale = pitch_scale
	stream_player.volume_linear = minf(volume, 1.0)
	
	add_child(stream_player)
	
	stream_player.play()
	
	await stream_player.finished
	stream_player.queue_free()


func play_bgm(bgm: AudioStream, loop: bool = false, loop_offset: float = 0.0, volume: float = 1.0, pitch_scale: float = 1.0) -> void:
	if bgm == null:
		push_error("Unable to play sfx:",bgm)
		return

	_stop_all_bgm()
	
	var stream_player: AudioStreamPlayer = AudioStreamPlayer.new()
	var bgm_bus_idx = AudioServer.get_bus_index("BGM")
	var bgm_bus = AudioServer.get_bus_name(bgm_bus_idx)
	
	stream_player.bus = bgm_bus
	stream_player.stream = bgm
	stream_player.stream.loop = loop
	stream_player.stream.loop_offset = loop_offset
	stream_player.volume_linear = volume
	stream_player.pitch_scale = pitch_scale
	
	add_child(stream_player)
	
	stream_player.play()
	
	if loop:
		bgm_streams.append(stream_player)
		return
	
	await stream_player.finished
	stream_player.queue_free()


func _stop_all_bgm() -> void:
	for stream_player in bgm_streams:
		if is_instance_valid(stream_player):
			stream_player.stop()
			stream_player.queue_free()
	bgm_streams.clear()

	for child in get_children():
		if child is AudioStreamPlayer and child.bus == BUS_BGM:
			child.stop()
			child.queue_free()
