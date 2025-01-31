#!/usr/bin/env python3

from __future__ import annotations
from pydantic import BaseModel, Field
from typing import Optional


class NBModel:


    class IPAddress(BaseModel):
        ip_version: int
        address: str


    class ConnectedInterface(BaseModel):
        device: NBModel.Device
        name: str
        ip_addresses: list[NBModel.IPAddress] = None


    class Tag(BaseModel):
        name: str


    class Interface(BaseModel):
        name: str
        tags: list[NBModel.Tag] = []
        ip_addresses: list[NBModel.IPAddress] = None
        connected_interface: Optional[NBModel.ConnectedInterface] = None
        untagged_vlan: Optional[NBModel.Vlan] = None


    class Vlan(BaseModel):
        vid: int


    class Device(BaseModel):
        name: str
        cf_bgp_asn: str | None = None
        interfaces: list[NBModel.Interface] = None

        
    class DeviceList(BaseModel):
        devices: list[NBModel.Device]
