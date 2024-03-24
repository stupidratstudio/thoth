extends Node2D

func set_coin(coin):
	$RichTextLabel.text = "Coins : " + String.num(coin)
