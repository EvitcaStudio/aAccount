#ENABLE LOCALCLIENTCODE
#BEGIN CLIENTCODE

Client
	command loginCommand()
		var usernameInput = this.getInterfaceElement('login_interface', 'usernameinput')
		var passwordInput = this.getInterfaceElement('login_interface', 'passwordinput')
		var usernameLabel = this.getInterfaceElement('login_interface','usernamewarninglabel')
		var passwordLabel = this.getInterfaceElement('login_interface','passwordwarninglabel')
		
		if (!usernameInput.text && !passwordInput.text)
			this.validateInputs(LOGIN_ALL, 'Required')
			
		else if (!usernameInput.text)
			this.validateInputs(USERNAME_SHOW, 'Required')

		else if (!passwordInput.text)
			this.validateInputs(PASSWORD_SHOW, 'Required')
		
		if (usernameInput.text && passwordInput.text)
			this.sendPacket(aNetwork.S_AACCOUNT_PACKETS.S_VALIDATE_LOGIN_PACKET, [usernameInput.text, passwordInput.text])

	command cycleLoginInputs()
		var userInput = this.getInterfaceElement('login_interface', 'usernameinput')
		var passInput = this.getInterfaceElement('login_interface', 'passwordinput')

		if (this.getFocus() === userInput)
			this.setFocus(passInput)
		else
			this.setFocus(userInput)
			
function checkCapsLogin(pEvent)
	if (pEvent.getModifierState('CapsLock'))
		Client.getInterfaceElement('login_interface', 'capsindicator').text = '<span style="pointer-events: none; font-family: Arial; font-size: 12px; color: #ffc800;">Caps lock is on</span>'
		return
	Client.getInterfaceElement('login_interface', 'capsindicator').text = ''

function openForgottenPasswordMenu()
	Client.callCommand('openRecoverMenu')
	
Interface
	LoginInterface
		atlasName = 'login_atlas'
		layer = HUD_LAYER

		LoginBackSplash
			iconName = 'login_backsplash'
			mouseOpacity = 0
			touchOpacity = 0
				
		LoginBackground
			interfaceType = 'WebBox'
			iconName = 'login_background'
			layer = HUD_LAYER + 1
			alpha = 0.9
			width = 268
			height = 384
		
		Inputs
			onFocus(pClient)
				this.iconState = ''
				this.setTransition()
				this.alpha = 1
			
			onUnfocus(pClient)
				if (!this.iconState)
					this.setTransition({ 'alpha': 0.8 }, 5, 20)

			onMouseEnter(pClient, pX, pY)
				if (!this.iconState)
					this.setTransition({ 'alpha': 1 }, 5, 30)
			
			onMouseExit(pClient, pX, pY)
				if (!this.iconState && pClient.getFocus() !== this)
					this.setTransition({ 'alpha': 0.8 }, 5, 20)

			UsernameInput
				interfaceType = 'TextInput'
				iconName = 'login_input'
				width = 214
				height = 29
				layer = HUD_LAYER + 2
				textStyle = { 'fill': '#fff', 'fontSize': 12, 'hPadding': 5, 'fontFamily': 'Arial' }
				
				onShow()
					if (this.getDOM())
						var element = this.getDOM().innerBox
						element.maxLength = MAX_USERNAME_LENGTH
						element.placeholder = 'Username'
						element.spellcheck = false
						element.required = true
						element.onkeydown = checkCapsLogin

				onFocus(pClient)
					override
					pClient.validateInputs(USERNAME_HIDE)
					Type.callFunction(this.parentType, 'onFocus', this)
				
			PasswordInput
				interfaceType = 'PassInput'
				iconName = 'login_input'
				width = 214
				height = 29
				layer = HUD_LAYER + 2
				textStyle = { 'fill': '#fff', 'fontSize': 12, 'hPadding': 5, 'fontFamily': 'Arial' }
				
				onShow()
					if (this.getDOM())
						var element = this.getDOM().innerBox
						element.maxLength = MAX_PASSWORD_LENGTH
						element.placeholder = 'Password'
						element.spellcheck = false
						element.required = true
						element.onkeydown = checkCapsLogin

				onFocus(pClient)
					override
					pClient.validateInputs(PASSWORD_HIDE)
					Type.callFunction(this.parentType, 'onFocus', this)

		UsernameWarningLabel
			iconName = 'warning_message_background'
			interfaceType = 'WebBox'
			width = 100
			height = 27
			mouseOpacity = 0
			touchOpacity = 0
			layer = HUD_LAYER + 2
			warningLabel = true
			text = '<span style="pointer-events: none; color: #ffffff; font-size: 12px; font-family: Arial;" class="center">Invalid</span>'

		PasswordWarningLabel
			iconName = 'warning_message_background'
			interfaceType = 'WebBox'
			width = 100
			height = 27
			mouseOpacity = 0
			touchOpacity = 0
			layer = HUD_LAYER + 2
			warningLabel = true
			text = '<span style="pointer-events: none; color: #ffffff; font-size: 12px; font-family: Arial;" class="center">Invalid</span>'
				
		LoginButton
			interfaceType = 'WebBox'
			iconName = 'login_button'
			width = 148
			height = 18
			layer = HUD_LAYER + 1
			
			onMouseClick(pClient, pX, pY, pButton)
				if (pButton === 1)
					if (this.isMousedDown())
						pClient.callCommand('loginCommand')
				
		RegisterButton
			interfaceType = 'WebBox'
			iconName = 'register_button'
			width = 173
			height = 25
			layer = HUD_LAYER + 1
			
			onMouseClick(pClient, pX, pY, pButton)
				if (pButton === 1)
					if (this.isMousedDown())
						pClient.openRegistration()

		GameLogo
			width = 108
			height = 108
			iconName = 'login_game_logo'
			layer = HUD_LAYER + 4
			mouseOpacity = 0
			touchOpacity = 0

		GameName
			width = 200
			height = 24
			layer = HUD_LAYER + 1
			interfaceType = 'WebBox'
			mouseOpacity = 0
			touchOpacity = 0

			onShow()
				this.text = '<div style="color: #ffffff; font-size: 18px; font-family: Arial;" class="center">' + GAME_NAME + '</div>'

		ViewPasswordButton
			iconName = 'view_password'
			width = 16
			height = 16
			plane = 2
			layer = HUD_LAYER + 7
			var viewEye = true
			var passwordShown = false

			function toggle()
				var passInput = Client.getInterfaceElement('login_interface', 'passwordinput')
				var element = passInput.getDOM().innerBox
				this.passwordShown = this.passwordShown ? false : true
				this.iconName = this.passwordShown ? 'view_password_hide' : 'view_password'
				element.type = element.type === 'password' ? 'text' : 'password'
				Client.validateInputs(PASSWORD_HIDE)

			onMouseClick(pClient, pX, pY, pButton)
				if (pButton === 1)
					if (this.isMousedDown())
						this.toggle()

			onMouseEnter(pClient, pX, pY)
				pClient.setMouseCursor('pointer')

			onMouseExit(pClient, pX, pY)
				pClient.setMouseCursor('')

		ForgotPasswordLabel
			width = 150
			height = 16
			interfaceType = 'WebBox'
			mouseOpacity = 0
			touchOpacity = 0
			layer = HUD_LAYER + 1
			text = '<div class="center forgot_password" onMouseClick="VS.World.global.openForgottenPasswordMenu();">Forgot Your Password?</div>'

		RegisterLabel
			width = 225
			height = 20
			interfaceType = 'WebBox'
			mouseOpacity = 0
			touchOpacity = 0
			layer = HUD_LAYER + 1
			text = '<div style="color: #ffffff; font-size: 12px; font-family: Arial;" class="center">Don\'t have an account? Register now!</div>'

		CapsIndicator
			width = 150
			height = 25
			layer = HUD_LAYER + 1
			mouseOpacity = 0
			touchOpacity = 0
			interfaceType = 'WebBox'
			text = '<span style="pointer-events: none; font-family: Arial; font-size: 12px; color: #ffc800;">Caps lock is on</span>'	

#END CLIENTCODE