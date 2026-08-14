extends MeshInstance3D
var spinning: bool = true
var speed: float = 120 # degrees per second
var sound_playing = true
func _physics_process(delta: float) -> void:
	if spinning:
		rotate_z(deg_to_rad(speed * delta))
		sound_playing = true
	else:
		sound_playing = false
func activate(ball: RigidBody3D):
	spinning = false
var gen := AudioStreamGenerator.new()
var player := AudioStreamPlayer.new()
var playback

# --- SOUND PARAMETERS ---
var base_freq := 180.0            # main hum frequency
var vibrato_speed := 0.8          # slow wobble
var vibrato_depth := 6.0          # pitch wobble amount

var blade_interval := 0.45        # seconds between blade passes
var blade_strength := 0.25        # how loud the bump is

var noise_amount := 0.02          # tiny randomness so it never loops
var lp_last := 0.0
var lp_cutoff := 0.1   # lower = softer
# --- INTERNAL STATE ---
var phase := 0.0
var blade_timer := 0.0

func _ready():
	gen.mix_rate = 44100
	player.stream = gen
	add_child(player)
	player.play()
	playback = player.get_stream_playback()


func _process(delta):
	if sound_playing:
		var frames := int(gen.mix_rate * delta)

		for i in frames:
			# --- Vibrato (slow wobble) ---
			var freq := base_freq + sin(phase * vibrato_speed) * vibrato_depth

			# --- Blade pass bump ---
			blade_timer += delta
			var amp := 0.18
			if blade_timer >= blade_interval:
				amp += blade_strength
				blade_timer = 0.0

			# --- Tiny randomness so it never loops ---
			amp += randf_range(-noise_amount, noise_amount)

			# --- Sawtooth wave ---
			var sample := amp * sin(phase * TAU)
			lp_last = lp_last + lp_cutoff * (sample - lp_last)
			sample = lp_last

			# --- Push stereo frame ---
			playback.push_frame(Vector2(sample, sample))

			# --- Advance phase ---
			phase += freq / gen.mix_rate
