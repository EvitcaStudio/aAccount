#ENABLE LOCALCLIENTCODE
#BEGIN CLIENTCODE
#BEGIN JAVASCRIPT
(() => {
	const engineWaitId = setInterval(() => {
		if (VS.Client && VS.World && VS.World.global && VS.World.global.aNetwork) {
			clearInterval(engineWaitId);
			let aAccount = {};
			if (VS.World.getCodeType() === 'local') {
				aAccount = VS.World.global.aAccount ? VS.World.global.aAccount : aAccount;
			}
			VS.World.global.aAccount = aAccount;
			VS.Client.___EVITCA_aAccount = true;
			// the max amount of slots this account can have
			aAccount.maxCharacterSlots = 4;
		}
	});
})();
#END JAVASCRIPT
#END CLIENTCODE	

#BEGIN SERVERCODE
#BEGIN JAVASCRIPT
// https://www.npmjs.com/package/bcrypt
const bcrypt = require('bcrypt');
const saltRounds = 10;
#END JAVASCRIPT
#END SERVERCODE

#BEGIN JAVASCRIPT

(() => {
	const PERIODIC_SAVE_INTERVAL = 1800000; // 30 Minutes

	const saveableStats = [];
	const saveableStyles = [];
	const saveableInfo = ['pName', 'oldx', 'oldy', 'mapName'];

	const engineWaitId = setInterval(function() {
		if (VS.World.global && VS.World.global.aNetwork) {
			clearInterval(engineWaitId);
			buildAccount();
		}
	});

	const buildAccount = () => {
		const aAccount = {};
		VS.World.global.aAccount = aAccount;
		// array that will store all taken usernames
		aAccount.usernameDatabase = [];
		// array that will store all taken player usernames
		aAccount.characterUsernameDatabase = [];
		// object that will store all account data for every account registered to the game
		aAccount.accountsDatabase = {};
		// object that will store all connected clients
		aAccount.clients = {};
		// a string of possible token chars
		aAccount.tokenCharacters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
		// a variable that is a boolean for if the library is in debug mode or not
		aAccount.debugging = false;
		// the max amount of slots this account can have
		aAccount.maxCharacterSlots = 4;
		// the interval at which the game saves crutial data.
		aAccount.saveDelay = Date.now() + PERIODIC_SAVE_INTERVAL;
		// the amount of confirmation checks the server has recieved from save functions that have completed.
		aAccount.endServerConfirmations = 0;
		// number of crutial save functions that must be run and accounted for before the server can safely close
		aAccount.endServerConfirmationChecks = 2; // saveAccountsDatabase // saveUserDatabase
		//Every time the periodic save happens, it must succesfully save all the clients before allowing the world to be considered "saved"
		aAccount.clientsToBeSavedConfirmations = 0;
		// Tracks the clients that need to be saved to be compared against the amount of clients already saved to determine if the world is saved
		aAccount.clientsToBeSaved = 0;
		// stored clients that have been grabbed in this wave of periodic saving
		aAccount.clientsToBeSavedAutomatically = [];
		// if the game is currently considered to be in a state where it is saving things
		aAccount.automaticSaving = false;
		// a var determining if the accoutn system is allowing new logins, if it is not then no account can login
		aAccount.LOCKED = false;

		// an array that includes the slot number of every available choice. If a slot with a number that is not in this array is clicked, then no load happens.
		aAccount.acceptedSlots = (function() {
			const slots = [];
			for (let i = 1; i <= aAccount.maxCharacterSlots; i++) {
				slots.push(i);
			}
			return slots;
		})();

		// toggle the debug mode, which allows descriptive text to be shown when things of notice happen
		aAccount.toggleDebug = function() {
			this.debugging = (this.debugging ? false : true);
		}

		// attach disconnect event to client
		aAccount.setDisconnectEvent = function(pClient) {
			if (!pClient.onDisconnectSet) {
				pClient._onDisconnect = pClient.onDisconnect;
				pClient.onDisconnectSet = true;
				pClient.aAccount = this;
				pClient.___EVITCA_aAccount = true;
				pClient.onDisconnect = function() {
					if (this.accountName) {
						if (this.loggedIn) {
							VS.World.global.aAccount.logout(this);
						}
					}
					if (this._onDisconnect) {
						this._onDisconnect.apply(this, arguments);
					}
				}
			}
		}

		// refresh the connected clients
		aAccount.refreshClients = function() {
			const ob = {};
			for (const client of VS.World.getClients()) {
				if (client.accountName && client.loggedIn) {
					ob[client.accountName] = client;
				}
			}
			this.clients = ob;
			return;
		}

		aAccount.loadDatabases = function() {
			this.loadUserDatabase();
			this.loadAccountsDatabase();
		}

		aAccount.saveDatabases = function(pEndServer=null) {
			this.saveAccountsDatabase(pEndServer);
			this.saveUserDatabase(pEndServer);	
		}

		// save the username database with the latest username data
		aAccount.saveUserDatabase = function(pEndServer=null) {
			if (VS.World.getCodeType() === 'server') {
				VS.File.writeSave('usernames/u_database', this.usernameDatabase, [this.finalizeServerShutdown, this, [pEndServer]]);
				if (this.debugging) {
					console.log('--Saved username database--');
				}
			}
		}

		// save the account database with the latest account data
		aAccount.saveAccountsDatabase = function(pEndServer=null) {
			if (VS.World.getCodeType() === 'server') {
				VS.File.writeSave('accounts/a_database', this.accountsDatabase, [this.finalizeServerShutdown, this, [pEndServer]]);
				if (this.debugging) {
					console.log('--Saved account database--');
				}
			}
		}

		// converts saved file into a object so you can use it as a variable 
		aAccount.loadUserDatabase = function() {
			if (VS.World.getCodeType() === 'server') {
				VS.File.readSave('usernames/u_database', this.finishLoadingUserDatabase.bind(this));
			}
		}

		// converts saved account file into a object so you can use it as a variable
		aAccount.loadAccountsDatabase = function() {
			if (VS.World.getCodeType() === 'server') {
				VS.File.readSave('accounts/a_database', this.finishLoadingAccountsDatabase.bind(this));
			}
		}	

		// callback function for finishing the loading of the username database
		aAccount.finishLoadingUserDatabase = function(pData, pError) {
			if (pError) {
				console.error('--Error loading username database--');
				return;
			}
				
			if (!pData) {
				this.usernameDatabase = [];
				if (this.debugging) {
					console.log('--Username database empty--');
				}
				return;
			}

			this.usernameDatabase = pData;
			if (this.debugging) {
				console.log('--Loaded username database--');
			}
		}

		// callback function finishing the loading of the accounts database
		aAccount.finishLoadingAccountsDatabase = function(pData, pError) {
			if (pError) {
				console.error('--Error loading accounts database--');
				return;
			}
				
			if (!pData) {
				this.accountsDatabase = {}
				if (this.debugging) {
					console.log('--Accounts database empty--');
				}
				return;
			}

			this.accountsDatabase = pData;
			if (this.debugging) {
				console.log('--Loaded accounts database--');
			}
		}

		// save the clients account
		aAccount.saveAccount = function(pClient) {
			if (VS.World.getCodeType() === 'server') {
				// _accountName debugging only
				pClient._accountName = pClient.accountName;
				VS.File.writeSave('accounts/' + pClient.accountName.slice(0, 3) + '/' + pClient.accountName, pClient.accountData, this.finishSave.bind(pClient));
				// send packet client side to show (in progress saving alert)
			}
		}

		// callback for finishing the saving of the clients account, the `this` is the client itself
		aAccount.finishSave = function(pError, pVylo=false) {
			if (pError) {
				console.error('Error saving ' + this._accountName + '\'s account');
				this._accountName = '';
				return;
			}

			if (aAccount.debugging) {
				console.log('--' + this._accountName + '\'s account saved--');
				this._accountName = '';
			}

			if (pVylo) {
				aAccount.login(this, pVylo);
			}
			// send packet client side to remove the (in progress saving alert)

			// mark this client with a temporary stamp that lets the account system know it was saved, that way if it is removed then the count can be adjusted
			this._automaticallySaved = true;
			// remove temporary var that stores your account name for debugging purposes

			aAccount.clientsToBeSavedConfirmations++;
			if (aAccount.automaticSaving) {
				if (aAccount.clientsToBeSavedConfirmations >= aAccount.clientsToBeSaved) {
					aAccount.clientsToBeSavedConfirmations = 0;
					aAccount.clientsToBeSaved = 0;
					aAccount.automaticSaving = false;
					for (const c of aAccount.clientsToBeSavedAutomatically) {
						// reset the temporary save indicator on the client
						c._automaticallySaved = false;
					}
					aAccount.clientsToBeSavedAutomatically = [];
					if (aAccount.debugging) {
						console.log('Automatic world saving completed. World has been saved.');
					}
					if (this.shutDownServer) {
						this.saveDatabases(this.shutDownServer);
					}
				}
			}
		}

		// load the clients account
		aAccount.loadAccount = function(pClient, pVylo=false) {
			if (VS.World.getCodeType() === 'server') {
				VS.File.readSave('accounts/' + pClient.accountName.slice(0, 3) + '/' + pClient.accountName, [this.finishLoadingAccount, pClient, [pVylo]]);
			}
		}

		// callback for finishing the loading of the clients account, the `this` is the client itself
		aAccount.finishLoadingAccount = function(pData, pError, pVylo=false) {
			if (pError) {
				console.error('Error loading ' + this.accountName + '\'s account');
				return;
			}
				
			this.accountData = pData;

			if (aAccount.debugging) {
				console.log('--' + this.accountName + '\'s account loaded--');
			}

			const otherClient = aAccount.clients[this.accountName];
			// if this account is already connected to the game
			if (otherClient && !pVylo) {
				// check if this client is actually signed in
				if (otherClient.loggedIn) {
					// if this client has a character logged in
					if (otherClient.mob.inGame) {
						// force the character to leave and save the account data
						aAccount.onCharacterLeave(otherClient);
						// take the account data of this other account since its more recent
						VS.Util.copyObject(this.accountData, otherClient.accountData);
						// reload slots with this data for the client joining
						VS.World.global.aNetwork.s_loadSlots(this);
					}
					// Forecfully logout the other account, but do not call for the mob to be logged out
					aAccount.logout(otherClient, true);
				}
			}

			if (pVylo) {
				VS.World.global.aNetwork.s_loadSlots(this);
			}

			aAccount.onLogin(this);
		}

		// loads a vylocity account instead of a custom account
		aAccount.loadVyloAccount = function(pClient) {
			const username = pClient.getAccountName();
			if (username === 'Guest' || username.match(VS.Util.regExp('^Guest\-(.*)$')) || username.match(VS.Util.regExp('^Guest[0-9]+$')) && !username.includes('@') || VS.World.getCodeType() === 'local') {
				// You are a guest according to vylo so you have to login in via a custom account system or you have no access to vylocity API so you have to register with the custom account system.
				pClient.sendPacket(VS.World.global.aNetwork.INTERFACE_PACKETS.C_SHOW_INTERFACE_PACKET, [VS.World.global.aNetwork.INTERFACE_CODES.LOGIN_INTERFACE_CODE]);
				return;
			}

			// if this account name isn't found in the database then you must be new
			if (!this.usernameDatabase.includes(username) && !this.accountsDatabase[username]) {
				this.setDisconnectEvent(pClient);
				let vylo = true;
				const ob = {};
				const ob2 = {};
				const ob3 = {};
				ob.username = username;
				ob3.username = username;
				ob3.characters = 0;
				ob3.backupCode = null;
				// make this account distinguishable from others
				ob3.vylo = true;
				ob3.kofi = false;
				ob3.patreon = false;
				ob3.tokens = 0;
				ob3.tester = false;
				ob3.lastLogin = null;
				this.usernameDatabase.push(username);
				this.accountsDatabase[username] = ob;
				ob2[username] = ob3;
				pClient.accountName = username;
				pClient._accountName = username;
				// save the account
				VS.File.writeSave('accounts/' + username.slice(0, 3) + '/' + username, ob2, [this.finishSave.bind, pClient, [vylo]]);
				// save userdatabase since its updated
				this.saveUserDatabase();
				// save accounts database since its updated here
				this.saveAccountsDatabase();
			} else {
				pClient.accountName = username;
				aAccount.login(pClient, true);
			}
			// load this account name
			// Show slots interface with loaded characters
		}

		aAccount.getAccountName = function(pClient) {
			return pClient.accountName;
		}

		aAccount.isVyloAccount = function(pClient) {
			return pClient.accountData[pClient.accountName].vylo;
		}

		// strip the account of its data
		aAccount.stripAccountData = function(pClient) {
			pClient.accountData = null;
			pClient.accountName = null;
			pClient._automaticallySaved = null;
			pClient.mob.inGame = false;
			pClient.loggedIn = false;
		}

		// login client
		aAccount.login = function(pClient, pVylo=false) {
			this.loadAccount(pClient, pVylo);
			pClient.setMacroAtlas('load_macro');
		}

		// logout client
		aAccount.logout = function(pClient) {
			if (pClient.mob.inGame) {
				// saves the client's character here
				this.onCharacterLeave(pClient);
			}

			// if the game is in the middle of saving
			if (this.automaticSaving) {
				// if this client is currently being tracked by the automatic saving system and hasn't already been saved then remove it
				if (!pClient._automaticallySaved && this.clientsToBeSavedAutomatically.includes(pClient)) {
					// remove it form the tracked clients being saved
					this.clientsToBeSavedAutomatically.splice(this.clientsToBeSavedAutomatically.indexOf(pClient), 1);
					// lower the amount of clients that need to be saved by the automatic save system since this client left
					this.clientsToBeSaved--;
				}
			}

			pClient.sendPacket(VS.World.global.aNetwork.INTERFACE_PACKETS.C_HIDE_INTERFACE_PACKET, [VS.World.global.aNetwork.INTERFACE_CODES.ALL_INTERFACES_CODE]);
			pClient.sendPacket(VS.World.global.aNetwork.INTERFACE_PACKETS.C_SHOW_INTERFACE_PACKET, [VS.World.global.aNetwork.INTERFACE_CODES.LOGIN_INTERFACE_CODE]);
			pClient.setMacroAtlas('login_macro');

			if (pClient.loggedIn) {
				this.saveAccount(pClient);
				this.onLogout(pClient);
			}

			this.stripAccountData(pClient);
		}

		// Called right after logging in via the account system
		aAccount.onLogin = function(pClient) {
			pClient.loggedIn = true;
			if (VS.World.getCodeType() === 'server') {
				pClient.accountData[pClient.accountName].lastLogin = this.getTime(true);
			}
			if (this.debugging) {
				console.log('--' + pClient.accountName + ' has logged in--');
			}
			this.refreshClients();
			if (pClient.onLogin && typeof(pClient.onLogin) === 'function') {
				pClient.onLogin();
			}
		}

		// Called right after logging out via the account system
		aAccount.onLogout = function(pClient) {
			// called after the player is already disconnected from the game or on the login screen
			// properly handle the player logging off, maybe remove this player from the online lists if included in any
			// update lists
			// update guild?
			// update squad?

			pClient.loggedIn = false;

			if (this.debugging) {
				console.log('--' + pClient.accountName + ' has logged out--');
			}
			this.refreshClients();
			if (pClient.onLogout && typeof(pClient.onLogout) === 'function') {
				pClient.onLogout();
			}
		}

		// when the character joins the game, not the client
		aAccount.onCharacterJoin = function(pClient, pNew=false) {
			const JOIN = 0;
			const NEW = 1;
			const OLD = 0;
			if (pClient.mob.onJoin && typeof(pClient.mob.onJoin) === 'function') {
				pClient.mob.onJoin(pNew);
				pClient.sendPacket(VS.World.global.aNetwork.C_AACCOUNT_PACKETS.C_CHARACTER_HANDLE_CONNECTION_PACKET, [JOIN, (pNew ? NEW : OLD)]);
			}
			pClient.mob.inGame = true;
			// pClient.setMacroAtlas('default_macro'); /* removed because there is no way to reasonably allow the correct macro to be set */
			this.saveAccount(pClient);
		}

		// when the character leaves the game, not the client
		aAccount.onCharacterLeave = function(pClient) {
			const LEAVE = 1;
			this.saveClientCharacter(pClient);
			if (pClient.mob.onLeave && typeof(pClient.mob.onLeave) === 'function') {
				pClient.mob.onLeave();
				pClient.sendPacket(VS.World.global.aNetwork.C_AACCOUNT_PACKETS.C_CHARACTER_HANDLE_CONNECTION_PACKET, [LEAVE]);
			}
			pClient.mob.inGame = false;
			VS.delDiob(pClient.mob);
		}

		// initiate a new character
		aAccount.initializeNewCharacter = function(pClient) {
			// for new characters only
			// this function will do alot of background things for you such as updating things with your saved data
			// this function will be the catalyst to all things a new player will do
			// this function will set the position of the new charater on the map at a newbie spawn
			if (VS.World.getCodeType() === 'server') {
				pClient.accountData[pClient.accountName].characters++;
			}
			aAccount.onCharacterJoin(pClient, true);
		}

		// initialize a loaded character
		aAccount.initializeLoadedCharacter = function(pClient) {
			// for loaded characters only
			// this function does alot of background things that will update things with your saved data
			// this function is used to apply all of your saved data back into the correct places.
			// updating the client with the needed information
			// such as letting your guild know you are online
			// sending the client a packet to show the default interfaces
			// building your inventory etc etc
			pClient.mob.setPos(pClient.mob.info.oldx, pClient.mob.info.oldy, pClient.mob.info.mapName);
			aAccount.onCharacterJoin(pClient);
		}

		// save the clients character
		aAccount.saveClientCharacter = function(pClient, pSaveAccount) {
			if (VS.World.getCodeType() === 'server') {
				const savedData = {};

				for (const a of saveableStats) {
					savedData[a] = pClient.mob.stats[a];
				}
					
				for (const b of saveableStyles) {
					savedData[b] = pClient.mob.style[b];
				}

				for (const c of saveableInfo) {
					savedData[c] = pClient.mob.info[c];
				}
				
				savedData.oldx = Math.round(pClient.mob.xPos);
				savedData.oldy = Math.round(pClient.mob.yPos);
				savedData.mapName = pClient.mob.mapName;
				pClient.accountData[pClient.accountName][pClient.mob.info.pName] = savedData;
				
				if (this.debugging) {
					console.log('--' + pClient.accountName + '\'s [Character]: ' + pClient.mob.info.pName + ' has been saved--');
				}
				if (pSaveAccount) {
					this.saveAccount(pClient);
				}
			}
		}

		// load the clients character
		aAccount.loadClientCharacter = function(pClient, pSlot) {
			if (VS.World.getCodeType() === 'server') {
				const player = VS.newDiob('Mob/Player');
				player.setPos(0, 0);
				pClient.setPlayerMob(player);
				// folders are the first 3 chars of a account name
				VS.File.readSave('accounts/' + pClient.accountName.slice(0, 3) + '/' + pClient.accountName, [this.finishLoadClientCharacter, pClient, [pSlot, pClient.accountName]]);
			}
		}

		// finish loading the character, the this in this function belongs to the client
		aAccount.finishLoadClientCharacter = function(pData, pError, pSlot, pAccountName) {
			let count = 0;
			if (pError) {
				if (aAccount.debugging) {
					console.error('Save file didn\'t load properly');
				}
				return;
			}

			if (!pData) {
				if (aAccount.debugging) {
					console.warn(pAccountName + ': There was no character save data to be loaded');
				}
				return;
			}
			
			for (const character of Object.keys(pData[pAccountName])) {
				// if it is a object, it is a character
				if (typeof(pData[pAccountName][character]) === 'object') {
					count++;
					// if you looped through the amount of characters, and the loop matches the slot u clicked, this must be the correct character
					if (count === pSlot) {
						for (const variable in pData[pAccountName][character]) {
							if (saveableInfo.includes(variable)) {
								this.mob.info[variable] = pData[pAccountName][character][variable];
							}

							if (saveableStats.includes(variable)) {
								this.mob.stats[variable] = pData[pAccountName][character][variable];
							}
							
							if (saveableStyles.includes(variable)) {
								this.mob.style[variable] = pData[pAccountName][character][variable];
							}
						}

						aAccount.initializeLoadedCharacter(this);
						if (aAccount.debugging) {
							console.log('--' + this.accountName + '\'s [Character]: ' + this.mob.info.pName + ' has been loaded');
						}
						return;
					}
				}
			}
		}

		// return the time to store for later use for calculating time
		aAccount.getTime = function(pFull) {
			const now = new Date();
			let meridiem = 'AM';
			let year = now.getFullYear();
			let month = now.getMonth() + 1;
			let day = now.getDate();
			let hour = now.getHours();
			let minute = now.getMinutes();
			let second = now.getSeconds();
			
			if (hour >= 12) {
				if (hour > 12) {
					hour -= 12;
				}
				meridiem = 'PM';
			}
				
			if (minute < 10) {
				minute = '0' + month;
			}

			if (second < 10) {
				second = '0' + second;
			}

			if (hour === 0) {
				hour = '12';
			}

			return pFull ? (month + '/' + day + '/' + year + '[' + hour + ':' + minute + ':' + second + '' + meridiem + ']') : ('[' + hour + ':' + minute + ':' + second + '' + meridiem + ']');
		}

		aAccount.checkUsernameDatabase = function(pClient, pUsername, pBackupCode, pInternal) {
			const MAX_PASSWORD_LENGTH = 25;
			const MIN_PASSWORD_LENGTH = 5;
			const MAX_USERNAME_LENGTH = 15;
			const MIN_USERNAME_LENGTH = 5;
			const MAX_BACKUP_CODE_LENGTH = 6;

			// check the format of pBackupCode
			for (const user of this.usernameDatabase) {
				if (pUsername.trim().toUpperCase() === user.trim().toUpperCase()) {
					if (pInternal) {
						return false;
					}
					pClient.sendPacket(VS.World.global.aNetwork.C_AACCOUNT_PACKETS.C_VERIFICATION_WARNING_PACKET, [3]);
					return false;
				}
			}

			if (pUsername.length < MIN_USERNAME_LENGTH || pUsername.length > MAX_USERNAME_LENGTH) {
				if (pInternal) {
					return false;
				}
				pClient.sendPacket(VS.World.global.aNetwork.C_AACCOUNT_PACKETS.C_VERIFICATION_WARNING_PACKET, [2]);
				return false;
			}
				
			if (this.isUsernameFormatted(pUsername)) {
				if (pInternal) {
					return true;
				}
				return true;
			}

			if (pInternal) {
				return false;
			}
			pClient.sendPacket(VS.World.global.aNetwork.C_AACCOUNT_PACKETS.C_VERIFICATION_WARNING_PACKET, [2]);
			return false;
		}

		// check if the username is formatted
		aAccount.isUsernameFormatted = function(pString) {
			if (!pString) {
				return false;
			}

			if (pString.match(VS.Util.regExp('[^A-Za-z0-9_-]', 'g'))) {
				return false;
			}
			return true;
		}

		// generate a token
		aAccount.generateToken = function(pCharacters) {
			let token = '';
			for (let i = 0; i < pCharacters; i++) {
				token += this.tokenCharacters.charAt(Math.floor(Math.random() * this.tokenCharacters.length));
			}

			return token;
		}

		// called when registration is completed, password is hashed and an account is created with the registered info, password is hashed and salted and password is stored as hash.
		aAccount.bcryptHash = function (pClient, pUsername, pPassword, pBackupCode) {
			if (VS.World.getCodeType() === 'server') {
				bcrypt.hash(pPassword, saltRounds, function(pError, pHash) {
					if (pError) {
						console.error('Error hashing password for: ' + pUsername);
						return;
					}
					const ob = {};
					const ob2 = {};
					const ob3 = {};
					ob.username = pUsername;
					ob.hash = pHash;
					ob3.username = pUsername;
					ob3.characters = 0;
					ob3.backupCode = pBackupCode;
					ob3.vylo = false;
					ob3.patreon = false;
					ob3.kofi = false;
					ob3.tokens = 0;
					ob3.tester = false;
					ob3.lastLogin = null;
					aAccount.usernameDatabase.push(pUsername);
					aAccount.accountsDatabase[pUsername] = ob;
					ob2[pUsername] = ob3;
					pClient.accountName = pUsername;
					pClient._accountName = pUsername;
					// save the account
					VS.File.writeSave('accounts/' + pUsername.slice(0, 3) + '/' + pUsername, ob2, aAccount.finishSave.bind(pClient));
					// save userdatabase since its updated
					aAccount.saveUserDatabase();
					// save accounts database since its updated here
					aAccount.saveAccountsDatabase();
					pClient.sendPacket(VS.World.global.aNetwork.INTERFACE_PACKETS.C_HIDE_INTERFACE_PACKET, [VS.World.global.aNetwork.INTERFACE_CODES.REGISTER_INTERFACE_CODE]);
				});
			}
		}

		// called when a client is logging in, chekcs the password against the one in the stored database, if the hash is correct then login is succesful
		aAccount.bcryptCompare = function(pClient, pUsername, pPassword) {
			if (VS.World.getCodeType() === 'server') {
				bcrypt.compare(pPassword, VS.World.global.aAccount.accountsDatabase[pUsername].hash, function(pError, pResult) {
					if (pError) {
						console.error('Error checking password for: ' + pUsername);
						return;
					}

					if (pResult) {
						aAccount.setDisconnectEvent(pClient);
						pClient.accountName = pUsername;
						aAccount.login(pClient);
						pClient.sendPacket(VS.World.global.aNetwork.INTERFACE_PACKETS.C_HIDE_INTERFACE_PACKET, [VS.World.global.aNetwork.INTERFACE_CODES.LOGIN_INTERFACE_CODE]);
						return;

					} else {
						pClient.sendPacket(VS.World.global.aNetwork.C_AACCOUNT_PACKETS.C_VERIFICATION_WARNING_PACKET, [0]);
					}
				});
			}
		}

		aAccount.periodicSave = function() {
			if (Date.now() >= this.saveDelay) {
				if (VS.World.getCodeType() === 'local') {
					this.saveDelay = Date.now() + PERIODIC_SAVE_INTERVAL ;
					return;
				}
				this.saveWorld();
			}
		}

		aAccount.saveWorld = function(pLogout, pEndServer=null) {
			if (VS.World.getCodeType() === 'local') {
				return;
			}

			this.clientsToBeSaved = 0;
			this.clientsToBeSavedConfirmations = 0;
			this.clientsToBeSavedAutomatically = [];
			this.automaticSaving = true;
			this.shutDownServer = null;

			if (pEndServer) {
				// means no accoutn can log in because the server is shutting down
				aAccount.LOCKED = true;
				this.shutDownServer = pEndServer;
				console.log('Server shutting down soon');
				// maybe send a packet to let the clients know when the server will end. Maybe send them a time window, and then count down on their client from then.
			}

			for (const client of VS.World.getClients()) {
				if (client.mob.inGame || client.loggedIn) {
					this.clientsToBeSaved++;
					this.clientsToBeSavedAutomatically.push(client)
				}
			}

			for (const client of VS.World.getClients()) {
				if (pLogout) {
					this.logout(client);
				} else {
					if (client.mob.inGame) {
						this.saveClientCharacter(client, true);
					}
				}
			}

			this.saveDelay = Date.now() + PERIODIC_SAVE_INTERVAL;
			this.refreshClients();
		}

		aAccount.finalizeServerShutdown = function(pError, pEndServer) {
			if (pError) {
				console.log('Error while saving/shutting down server');
				return;
			}

			if (pEndServer) {
				this.endServerConfirmations++
				if (this.endServerConfirmations === this.endServerConfirmationChecks) {
					pEndServer();
				}
			}
		}

		const periodicSaveInterval = setInterval(function() {
			aAccount.periodicSave();
		}, PERIODIC_SAVE_INTERVAL);

		aAccount.loadDatabases();

		if (aAccount.debugging) {
			console.log('Automatic save system has started');
		}
	}
})();

#END JAVASCRIPT
