class_name Reward_WaveComp extends Base_WaveComp



func Notifiy(data : Dictionary) -> void:
	if data.type == NOTIFICATION_TYPES.COMPLETED:
		rewards.UseAsReward()
