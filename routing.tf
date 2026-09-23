resource "azurerm_route_table" "spoke1_rt_table" {
  name                = "spoke1-route-table"
  location            = azurerm_resource_group.hub_spoke.location
  resource_group_name = azurerm_resource_group.hub_spoke.name

  route {
    name                   = "spoke1-route"
    address_prefix         = "10.2.0.0/16"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.0.2.4"
  }
}

resource "azurerm_route_table" "spoke2_rt_table" {
  name                = "spoke2-route-table"
  location            = azurerm_resource_group.hub_spoke.location
  resource_group_name = azurerm_resource_group.hub_spoke.name

  route {
    name                   = "spoke2-route"
    address_prefix         = "10.1.0.0/16"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.0.2.4"
  }
}

resource "azurerm_subnet_route_table_association" "spoke1_rt_association" {
  subnet_id      = azurerm_subnet.spoke1_workload.id
  route_table_id = azurerm_route_table.spoke1_rt_table.id

}

resource "azurerm_subnet_route_table_association" "spoke2_rt_association" {
  subnet_id      = azurerm_subnet.spoke2_workload.id
  route_table_id = azurerm_route_table.spoke2_rt_table.id

}