extends LevelInterface
class_name Level1

@onready var party_pop: GPUParticles2D = $Collectibles/PartyPop

func enter_level() -> void:
	AudioManager.play_bgm(AudioManager.BGMTEST_2)
	
	var viewport = get_viewport_rect().size
