ItemBase = ItemBase or class()

--品质
ItemQuality =
{
    White = 1,
    Green = 2,
    Blue = 3,
    Purple = 4,
    Orange = 5,
}

--大类
ItemType = 
{
    Equipment = 1,
    Medicine = 2,
    Task = 3,
    Gift = 4,
}

--装备子类
EquipmentType = 
{
    Weapon = 1,
    Helmet = 2,
    Breastplate = 3,
    Legging = 4,
    Boot = 5,
}

MedicineType =
{
    Hp = 1,
    Mp = 2,
}

function ItemBase:ctor()
	self.item_id = nil
    self.type = nil
    self.sub_type = nil
    self.quality = nil
    self.value = nil
    self.name = nil
    self.describe = nil
end

function ItemBase:onUse()
end