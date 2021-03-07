BattleCommand_StartRain:
; startrain

	ld a, [wBattleWeather]
	cp WEATHER_RAIN
	jr z, .failed
	
	ld a, WEATHER_RAIN
	ld [wBattleWeather], a
	ld a, 5
	ld [wWeatherCount], a
	call AnimateCurrentMove
	ld hl, DownpourText
	jp StdBattleTextBox
	
.failed
	call AnimateFailedMove
	jp PrintButItFailed

