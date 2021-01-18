ModUtil.RegisterMod("ModConfigMenu")

ModConfigMenu.Menus = {}
ModConfigMenu.CurrentMenuIdx = 1

function ModConfigMenu.Register(config)
  table.insert(ModConfigMenu.Menus, config)
end

local function PrettifyName( name )
  local first = true
  local prettyName = name:gsub("%u", function(c)
    if first then
      first = false
      return c
    else
      return ' ' .. c
    end
  end)
  return prettyName
end

local function UpdateCheckBox( button, value )
  local radioButtonValue = "RadioButton_Unselected"
  if value then
    radioButtonValue = "RadioButton_Selected"
  end
  SetThingProperty({
    DestinationId = button.Id,
    Property = "Graphic",
    Value = radioButtonValue
  })
end

local function ShowCurrentMenu( screen )
  local rowStartX = 350
  local columnSpacingX = 600
  local itemLocationX = rowStartX
  local itemLocationY = 250
  local itemSpacingX = 250
  local itemSpacingY = 50
  local itemsPerRow = 3
  
  local parentComponents = screen.Components

  -- clear previous menu
  local ids = {}
  for name, component in pairs(screen.MenuComponents) do
    parentComponents[k] = nil
    table.insert(ids, component.Id)
  end
  CloseScreen( ids )
  screen.MenuComponents = {}
  local components = screen.MenuComponents

  local currentMenu = ModConfigMenu.Menus[ModConfigMenu.CurrentMenuIdx]

  ModifyTextBox({
    Id = parentComponents["SelectedMenu"].Id,
    Text = currentMenu.ModName or "Unknown Mod"
  })

  local itemsInRow = 0
  for name, value in orderedPairs( currentMenu ) do
    if value == true or value == false then
      itemsInRow = itemsInRow + 1
      if itemsInRow > itemsPerRow then
        itemLocationX = rowStartX
        itemLocationY = itemLocationY + itemSpacingY
        itemsInRow = itemsInRow - itemsPerRow
      end
      components[name .. "TextBox"] = CreateScreenComponent({ 
        Name = "BlankObstacle", 
        Scale = 1,
        X = itemLocationX,
        Y = itemLocationY,
        Group = "Combat_Menu" })
      CreateTextBox({ 
        Id = components[name .. "TextBox"].Id,
        Text = PrettifyName(name),
        Color = Color.BoonPatchCommon,
        FontSize = 16,
        OffsetX = 0, OffsetY = 0,
        Font = "AlegrayaSansSCRegular",
        ShadowBlur = 0, ShadowColor = { 0, 0, 0, 1 }, ShadowOffset = { 0,  2 },
        Justification = "Center"
      })
      local previousItemLocationX = itemLocationX
      itemLocationX = itemLocationX + itemSpacingX
      components[name .. "CheckBox"] = CreateScreenComponent({
        Name = "RadioButton",
        Scale = 1,
        X = itemLocationX,
        Y = itemLocationY, 
        Group = "CombatMenu"
      })
      UpdateCheckBox(components[name .. "CheckBox"], value)
      components[name .. "CheckBox"].MenuItemName = name
      components[name .. "CheckBox"].OnPressedFunctionName = "ModConfigMenu__ToggleBoolean"
      CreateTextBox({ 
        Id = components[name .. "CheckBox"].Id,
        FontSize = 16,
        OffsetX = 0, OffsetY = 0,
        Font = "AlegrayaSansSCRegular",
        Justification = "Center"
      })
      itemLocationX = previousItemLocationX + columnSpacingX
    end
  end

  for k, v in pairs(components) do
    parentComponents[k] = v
  end
end

function ModConfigMenu__MenuLeft( screen, button )
  ModConfigMenu.CurrentMenuIdx = ModConfigMenu.CurrentMenuIdx - 1
  if ModConfigMenu.CurrentMenuIdx < 1 then
    ModConfigMenu.CurrentMenuIdx = #ModConfigMenu.Menus
  end
  ShowCurrentMenu( screen )
end

function ModConfigMenu__MenuRight( screen, button )
  ModConfigMenu.CurrentMenuIdx = ModConfigMenu.CurrentMenuIdx + 1
  if ModConfigMenu.CurrentMenuIdx > #ModConfigMenu.Menus then
    ModConfigMenu.CurrentMenuIdx = 1
  end
  ShowCurrentMenu( screen )
end

function ModConfigMenu__ToggleBoolean(screen, button)
  local menu = ModConfigMenu.Menus[ModConfigMenu.CurrentMenuIdx]
  local name = button.MenuItemName
  menu[name] = not menu[name]
  UpdateCheckBox(button, menu[name])
end

function ModConfigMenu__Open()
  -- TODO: find a better place to put the button, so
  -- we don't conflict with the seed selector mod
  CloseAdvancedTooltipScreen()

  local components = {}
  local screen = {
    Components = components,
    MenuComponents = {},
    CloseAnimation  = "QuestLogBackground_Out"
  }
  OnScreenOpened({ Flag = screen.Name, PersistCombatUI = true})
  FreezePlayerUnit()
  EnableShopGamepadCursor()
  SetConfigOption({ Name = "FreeFormSelectWrapY", Value = false })
  SetConfigOption({ Name = "FreeFormSelectStepDistance", Value = 8 })

  components.ShopBackgroundDim = CreateScreenComponent({ Name = "rectangle01", Group = "Combat_Menu"})
  components.ShopBackgroundSplatter = CreateScreenComponent({ Name = "LevelUpBackground", Group = "Combat_Menu"})
  components.ShopBackground = CreateScreenComponent({ Name = "rectangle01", Group = "Combat_Menu"})

  SetAnimation({ DestinationId = components.ShopBackground.Id, Name = "QuestLogBackgroun_In", OffsetY = 30 })

  SetScale({ Id = components.ShopBackgroundDim.Id, Fraction = 4})
  SetColor({ Id = components.ShopBackgroundDim.Id, Color = { 0.090, 0.055, 0.157, 0.8 } })

  PlaySound({ Name = "/SFX/Menu Sounds/FatedListOpen" })

  wait(0.2)

  -- Title
  CreateTextBox({ Id = components.ShopBackground.Id, Text = "Configure your Mods", FontSize = 34, OffsetX = 0, OffsetY = -460,
    Color = Color.White, Font = "SpectralSCLightTitling", ShadowBlur = 0, ShadowColor = { 0, 0, 0, 1 }, ShadowOffset = { 0, 2 },
    Justification = "Center" })

  -- Close Button
  components.CloseButton = CreateScreenComponent({ Name = "ButtonClose", Scale = 0.7, Group = "Combat_Menu"})
  Attach({ Id = components.CloseButton.Id, DestinationId = components.ShopBackground.Id, OffsetX = -6, OffsetY = 456 })
  components.CloseButton.OnPressedFunctionName = "ModConfigMenu__Close"
  components.CloseButton.ControlHotkey = "Cancel"

  components["MenuLeft"] = CreateScreenComponent({
    Name = "ButtonCodexLeft",
    X = 650,
    Y = 175,
    Scale = 1.0,
    Group = "Combat_Menu"
  })

  components["MenuLeft"].OnPressedFunctionName = "ModConfigMenu__MenuLeft"

  components["MenuRight"] = CreateScreenComponent({
    Name = "ButtonCodexRight",
    X = 1300,
    Y = 175,
    Scale = 1.0,
    Group = "Combat_Menu"
  })

  components["MenuRight"].OnPressedFunctionName = "ModConfigMenu__MenuRight"

  components["SelectedMenu"] = CreateScreenComponent({
    Name = "BlankObstacle",
    X = 975,
    Y = 175,
    Scale = 0.5,
    Group = "Combat_Menu"
  })

  components["MenuRight"].OnPressedFunctionName = "ModConfigMenu__MenuRight"

  CreateTextBox({
    Id = components["SelectedMenu"].Id,
    Text = "",
    OffsetX = 0, OffsetY = 0, 
    Color = Color.White,
    Font = "AlegreyaSansSCRegular",
    ShadowBlur = 0, ShadowColor = { 0, 0, 0, 1 }, ShadowOffset = { 0, 2 },
    Justification = "Center"
  })

  ShowCurrentMenu( screen )
  screen.KeepOpen = true
  thread( HandleWASDInput, screen )
  HandleScreenInput( screen )
end

function ModConfigMenu__Close( screen, button )
  DisableShopGamepadCursor()
  SetConfigOption({ Name = "FreeFormSelectWrapY", Value = false })
  SetConfigOption({ Name = "FreeFormSelectStepDistance", Value = 16 })
  SetConfigOption({ Name = "FreeFormSelectSuccessDistanceStep", Value = 8})
  SetAnimation({ DestinationId = screen.Components.ShopBackground.Id, Name = screen.CloseAnimation })
  PlaySound({ Name = "/SFX/Menu Sounds/FatedListClose" })
  CloseScreen( GetAllIds( screen.Components ), 0.1)
  UnfreezePlayerUnit()
  screen.KeepOpen = false
  OnScreenClosed({ Flag = screen.Name })
end

local config = {
  ModName = "Meat Loaf",
  WantYou = true,
  NeedYou = true,
  LoveYou = false,
  BeSad = false,
  TwoOutOfThreeIsBad = false
}

ModConfigMenu.Register(config)

local config2 = {
  ModName = "Traditional",
  KnewYouWereComing = false,
  BakedACake = false
}

ModConfigMenu.Register(config2)

ModUtil.WrapBaseFunction("CreatePrimaryBacking", function ( baseFunc )
  local components = ScreenAnchors.TraitTrayScreen.Components

  components.ModConfigButton = CreateScreenComponent({ Name = "ButtonDefault", Scale = 1.0, Group = "Combat_Menu_TraitTray", X = CombatUI.TraitUIStart + 105, Y = 930 })
  components.ModConfigButton.OnPressedFunctionName = "ModConfigMenu__Open"
  CreateTextBox({ Id = components.ModConfigButton.Id,
      Text = "Configure Mods",
      OffsetX = 0, OffsetY = 0,
      FontSize = 22,
      Color = Color.White,
      Font = "AlegreyaSansSCRegular",
      ShadowBlur = 0, ShadowColor = {0,0,0,1}, ShadowOffset={0, 2},
      Justification = "Center",
      DataProperties =
      {
        OpacityWithOwner = true,
      },
    })
  Attach({ Id = components.ModConfigButton.Id, DestinationId = components.ModConfigButton, OffsetX = 500, OffsetY = 500 })
  baseFunc()
end, ModConfigMenu)

