# CodeVault API Documentation

The `CodeVault` class provides a system for managing redeemable codes in Roblox. This API allows for code generation, redemption, management, and data storage.

## CodeVault Overview

`CodeVault` is a class used to handle redeemable codes for various purposes, such as promotions or rewards. It uses Roblox's `DataStoreService` to persist code data between sessions.

## Type Definitions

### `Code`

Represents a redeemable code with the following properties:

- `RedeemTimes` (`number`): The maximum number of times the code can be redeemed. `-1` for unlimited.
- `ExpirationTime` (`number`): The timestamp at which the code expires. `-1` for no expiration.
- `Redeemers` (`{number}`): A list of user IDs who have redeemed the code.

### `CodeVault`

Represents the main class for managing codes, with the following functions:

## Functions

### `CodeVault.new() -> CodeVault`

Creates a new `CodeVault` instance. Initializes the code list by loading from the data store.

### `CodeVault:GenerateCode(codeStr: string, redeemTimes: number?, expirationTime: number?) -> Code`

Generates a new code and adds it to the vault. Optional parameters:
- `redeemTimes`: Maximum number of times the code can be redeemed.
- `expirationTime`: Timestamp at which the code will expire.

### `CodeVault:RedeemCode(plr: Player, codeStr: string) -> (boolean, string)`

Redeems a code for a player. Returns a tuple where:
- `boolean`: Success status.
- `string`: Message indicating the result.

### `CodeVault:DeleteCode(codeStr: string)`

Deletes a specified code from the vault.

### `CodeVault:IsCodeExpired(codeStr: string) -> boolean`

Checks if a code has expired.

### `CodeVault:GetCodeInfo(codeStr: string) -> (boolean, Code?)`

Gets the information of a specified code. Returns a tuple where:
- `boolean`: Whether the code exists.
- `Code?`: The code details, if it exists.

### `CodeVault:GetRemainingRedeemTimes(codeStr: string) -> (boolean, number?)`

Gets the number of remaining redemptions for a code. Returns a tuple where:
- `boolean`: Whether the code exists.
- `number?`: Remaining redemptions or `math.huge` for unlimited.

### `CodeVault:ClearExpiredCodes() -> number`

Clears all expired codes from the vault. Returns the number of codes cleared.

### `CodeVault:_SaveCodes()`

Saves the current codes to the data store. This method is automatically called when codes are changed.

### `CodeVault:_LoadCodes()`

Loads codes from the data store. This method is called when a new `CodeVault` instance is created.

### `CodeVault:UpdateCodeDetails(codeStr: string, redeemTimes: number?, expirationTime: number?) -> (boolean, string)`

Updates the details of an existing code. Returns a tuple where:
- `boolean`: Success status.
- `string`: Message indicating the result.

### `CodeVault:ListCodes() -> {[string]: {RedeemTimes: number, ExpirationTime: number}}`

Lists all codes with their redeem times and expiration times.

### `CodeVault:CountTotalCodes() -> number`

Counts the total number of codes in the vault.

### `CodeVault:GetRedeemersList(codeStr: string) -> (boolean, {number}?)`

Gets a list of user IDs who have redeemed a specified code. Returns a tuple where:
- `boolean`: Whether the code exists.
- `{number}?`: List of user IDs.

## Example Usage

```lua
local CodeVault = require(game.ServerScriptService.CodeVault)

local vault = CodeVault.new()
vault:GenerateCode("SPECIALCODE", 5, tick() + 86400)
local success, message = vault:RedeemCode(plr, "SPECIALCODE")
print(message)
```
