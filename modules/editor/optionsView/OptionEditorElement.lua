-- Template: file://./OptionEditorElement.xml
---@class MapPinEnhancedOptionEditorElementMixin : Frame
---@field label FontString
---@field highlight Texture
---@field option OptionObjectVariantsTyped
---@field formElement FormElement
---@field optionHolder Frame
---@field type FormType
---@field info Frame -- defining it as a frame for now
MapPinEnhancedOptionEditorElementMixin = {}


---@param formElement FormElement
function MapPinEnhancedOptionEditorElementMixin:SetFormElement(formElement)
    assert(formElement, "formElement must be a valid frame")
    self.formElement = formElement
    formElement:SetParent(self.optionHolder)
    formElement:ClearAllPoints()
    formElement:SetPoint("RIGHT", 0, 0)
    formElement:Show()
    formElement:SetPropagateMouseMotion(true)
end

---@param optionData OptionObjectVariantsTyped
function MapPinEnhancedOptionEditorElementMixin:Setup(optionData)
    self.option = optionData
    self.label:SetText(optionData.label)
    self.formElement:Setup(optionData)
end

function MapPinEnhancedOptionEditorElementMixin:Update()
    if not self.option then
        return
    end
    self.label:SetText(self.option.label)
    self.formElement:Setup(self.option)
end
