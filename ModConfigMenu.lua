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

local function CheckBoxText( value )
  if value then
    return "{!Icons.CheckboxFilled}"
  else
    return "{!Icons.CheckboxEmpty}"
  end
end

local function ShowCurrentMenu( screen )
  local itemLocationX = 1400
  local itemLocationY = 560
  local itemSpacingX = 100
  local itemSpacingY = 50
  
  screen.MenuComponents = {}
  local components = screen.MenuComponents

  local currentMenu = ModConfigMenu.Menus[ModConfigMenu.CurrentMenuIdx]
  for name, value in pairs( currentMenu ) do
    if value == true or value == false then
      components[name .. "TextBox"] = CreateScreenComponent({ 
        Name = "BlankObstacle", 
        Scale = 1,
        X = itemLocationX,
        Y = itemLocationY,
        Group = "Combat_Menu" })
      CreateTextBox({ 
        Id = components[name .. "TextBox"].Id,
        Text = PrettifyName(name),
        Color = { 245, 200, 47, 255 },
        FontSize = 48,
        OffsetX = 0, OffsetY = 0,
        Font = "AlegrayaSansSCBold",
        Justification = "Center"
      })
      local previousItemLocationX = itemLocationX
      itemLocationX = itemLocationX + itemSpacingX
      components[name .. "CheckBox"] = CreateScreenComponent({
        Name = "ButtonDefault",
        Scale = 1,
        X = itemLocationX,
        Y = itemLocationY, 
        Group = "CombatMenu"
      })
      components[name .. "CheckBox"].MenuItemName = name
      components[name .. "CheckBox"].OnPressedFunctionName = "ModConfigMenu__ToggleBoolean"
      CreateTextBox({ 
        Id = components[name .. "CheckBox"].Id,
        Text = CheckBoxText(value),
        Color = { 245, 200, 47, 255 },
        FontSize = 48,
        OffsetX = 0, OffsetY = 0,
        Font = "AlegrayaSansSCBold",
        Justification = "Center"
      })
      itemLocationX = previousItemLocationX
      itemLocationY = itemLocationY + itemSpacingY
    end
  end
end

local function CloseCurrentMenu()
  CloseScreen( GetAllIds( screen.MenuComponents ), 0.1)
end

function ModConfigMenu__ToggleBoolean(screen, button)
  local name = button.MenuItemName
  local menu = ModConfigMenu.Menus[ModConfigMenu.CurrentMenuIdx]
  menu[name] = not menu[name]
  ModifyTextBox({ Id = button.Id, Text = CheckBoxText(menu[name]) })
end

function ModConfigMenu__Open()
  local components = {}
  local screen = {
    Components = components,
    CloseAnimation  = "QuestLogBackground_Out"
  }
  -- OnScreenOpened({ Flag = screen.Name, PersistCombatUI = true})
  FreezePlayerUnit()
  EnableShopGamepadCursor()

  components.ShopBackgroundDim = CreateScreenComponent({ Name = "rectangle01", Group = "Combat_Menu"})
  components.ShopBackgroundSplatter = CreateScreenComponent({ Name = "LevelUpBackground", Group = "Combat_Menu"})
  components.ShopBackground = CreateScreenComponent({ Name = "rectangle01", Group = "Combat_Menu"})

  SetAnimation({ DestinationId = components.ShopBackground.Id, Name = "QuestLogBackgroun_In", OffsetY = 30 })

  SetScale({ Id = components.ShopBackgroundDim.Id, Fraction = 4})
  SetColor({ Id = components.ShopBackgroundDim.Id, Color = { 0.090, 0.055, 0.157, 0.8 } })

  PlaySound({ Name = "/SFX/Menu Sounds/FatedListOpen" })

  wait(0.2)

  -- Title
  CreateTextBox({ Id = components.ShopBackground.Id, Text = "Configure your mods.", FontSize = 34, OffsetX = 0, OffsetY = -460,
    Color = Color.White, Font = "SpectralSCLightTitling", ShadowBlur = 0, ShadowColor = { 0, 0, 0, 1 }, ShadowOffset = { 0, 2 },
    Justification = "Center" })

  -- Close Button
  components.CloseButton = CreateScreenComponent({ Name = "ButtonClose", Scale = 0.7, Group = "Combat_Menu"})
  Attach({ Id = components.CloseButton.Id, DestinationId = components.ShopBackground.Id, OffsetX = -6, OffsetY = 456 })
  components.CloseButton.OnPressedFunctionName = "ModConfigMenu__Close"
  components.CloseButton.ContgrolHotkey = "Cancel"

  ShowCurrentMenu( screen )
end

function ModConfigMenu__Close()
  DisableShopGamepadCursor()
  SetAnimation({ DestinationId = screen.Components.Shopbackground.Id, Name = screen.CloseAnimation })
  PlaySound({ Name = "/SFX/Menu Sounds/FatedListClose" })
  CloseCurrentMenu()
  CloseScreen( GetAllIds( screen.Components ), 0.1)
  UnfreezePlayerUnit()
  -- screen.KeepOpen = false
  -- OnScreenClosed({ Flag = screen.Name })
end

local config = {
  BakeACake = true,
  WashTheDishes = false
}

ModConfigMenu.Register(config)
