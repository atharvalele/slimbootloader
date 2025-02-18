/** @file
  ACPI DSDT table

  Copyright (c) 2011 - 2017, Intel Corporation. All rights reserved.<BR>
  SPDX-License-Identifier: BSD-2-Clause-Patent
**/
#include "Base.h"
#include <PlatformBoardId.h>

#define CPU_TGL                 1
#define PCH_TGL                 1

// Definitions for INTB (Interrupt descriptor buffer method)
#define INT_LEVEL_TRIG  0
#define INT_EDGE_TRIG   1
#define INT_ACTIVE_LOW  0
#define INT_ACTIVE_HIGH 1

DefinitionBlock (
  "DSDT.aml",
  "DSDT",
  0x02, // DSDT revision.
        // A Revision field value greater than or equal to 2 signifies that integers
        // declared within the Definition Block are to be evaluated as 64-bit values
  "INTEL",   // OEM ID (6 byte string)
  "SKL     ",// OEM table ID  (8 byte string)
  0x0 // OEM version of DSDT table (4 byte Integer)
)

// BEGIN OF ASL SCOPE
{
  External(LHIH)
  External(LLOW)
  External(IGDS)
  External(LIDS)
  External(BRTL)
  External(ALSE)
  External(GSMI)
  External(\_SB.PC00.GFX0.ALSI)
  External(\_SB.PC00.GFX0.CLID)
  External(\_SB.PC00.GFX0.CDCK)
  External(\_SB.PC00.GFX0.CBLV)
  External(\_SB.PC00.GFX0.GSSE)
  External(\_SB.PC00.GFX0.DD1F, DeviceObj)
  External(\_SB.PC00.GFX0.DD2F, DeviceObj)
  External(\_SB.PC00.GFX0.GDCK, MethodObj)
  External(\_SB.PC00.GFX0.GHDS, MethodObj)
  External(\_SB.PC00.GFX0.AINT, MethodObj)
  External(\_SB.PC00.GFX0.GLID, MethodObj)
  External(\_SB.PC00.GFX0.GSCI, MethodObj)
  External(\_SB.PR00._PSS, MethodObj)
  External(\_SB.PR00.LPSS, PkgObj)
  External(\_SB.PR00.TPSS, PkgObj)
  External(\_SB.PR00._PPC, MethodObj)
  External(\_SB.CPPC, IntObj)
  External(\_TZ.TZ00, DeviceObj)
  External(\_TZ.ETMD, IntObj)
  External(\_TZ.FN00._OFF, MethodObj)
  External(\_SB.PC00.TXHC, DeviceObj) // CPU XHCI object of TCSS, it is a must existed object for CPU TCSS
  // Miscellaneous services enabled in Project

  Include ("AmlUpd.asl")
  Include ("PlatformNvs.asl")
  Include ("PciTree.asl")
  Include ("TimeAndAlarmDevice.asl")


  if(LEqual(ECR1,1)){
    Scope(\_SB.PC00) {
      //
      // PCI-specific method's GUID
      //
      Name(PCIG, ToUUID("E5C937D0-3553-4d7a-9117-EA4D19C3434D"))
      //
      // PCI's _DSM - an attempt at modular _DSM implementation
      // When writing your own _DSM function that needs to include PCI-specific methods, do this:
      //
      // Method(_YOUR_DSM,4){
      //   if(Lequal(Arg0,PCIG)) { return(PCID(Arg0,Arg1,Arg2,Arg3)) }
      //   ...continue your _DSM by checking different GUIDs...
      //   else { return(0) }
      // }
      //
      Method(PCID, 4, Serialized) {
        If(LEqual(Arg0, PCIG)) {         // PCIE capabilities UUID
          If(LGreaterEqual(Arg1,3)) {                                              // revision at least 3
            If(LEqual(Arg2,0)) { Return (Buffer(2){0x01,0x03}) }                   // function 0: list of supported functions
            If(LEqual(Arg2,8)) { Return (1) }                                      // function 8: Avoiding Power-On Reset Delay Duplication on Sx Resume
            If(LEqual(Arg2,9)) { Return (Package(5){50000,Ones,Ones,50000,Ones}) } // function 9: Specifying Device Readiness Durations
          }
        }
        return (Buffer(1){0})
      }
    }//scope
  }//if

  Scope(\_SB.PC00) {
    //PciCheck, Arg0=UUID, returns true if support for 'PCI delays optimization ECR' is enabled and the UUID is correct
    Method(PCIC,1,Serialized) {
      If(LEqual(ECR1,1)) {
        If(LEqual(Arg0, PCIG)) {
          return (1)
        }
      }
      return (0)
    }

    //
    // Create I2C Bus Resource descriptor for _CRS usage
    // Arg0 - I2C bus address of the connection (Slave Address)
    // Arg1 - I2C controller number (Resource Source)
    // Returns buffer with 'I2cSerialBus' resource descriptor
    //
    Method (IICB, 2, Serialized) {
      Switch (ToInteger(Arg1)) {
        Case(0) { Name (IIC0, ResourceTemplate () { I2cSerialBus (0, ControllerInitiated, 400000, AddressingMode7Bit,
          "\\_SB.PC00.I2C0", 0x00, ResourceConsumer, DEV0,) })
          CreateWordField (IIC0, DEV0._ADR, DAD0)
          Store (Arg0, DAD0)
          Return (IIC0) }
        Case(1) { Name (IIC1 , ResourceTemplate () { I2cSerialBus (0, ControllerInitiated, 400000, AddressingMode7Bit,
          "\\_SB.PC00.I2C1", 0x00, ResourceConsumer, DEV1,) })
          CreateWordField (IIC1, DEV1._ADR, DAD1)
          Store (Arg0, DAD1)
          Return (IIC1) }
        Case(2) { Name (IIC2 , ResourceTemplate () { I2cSerialBus (0, ControllerInitiated, 400000, AddressingMode7Bit,
          "\\_SB.PC00.I2C2", 0x00, ResourceConsumer, DEV2,) })
          CreateWordField (IIC2, DEV2._ADR, DAD2)
          Store (Arg0, DAD2)
          Return (IIC2) }
        Case(3) { Name (IIC3 , ResourceTemplate () { I2cSerialBus (0, ControllerInitiated, 400000, AddressingMode7Bit,
          "\\_SB.PC00.I2C3", 0x00, ResourceConsumer, DEV3,) })
          CreateWordField (IIC3, DEV3._ADR, DAD3)
          Store (Arg0, DAD3)
          Return (IIC3) }
        Case(4) { Name (IIC4 , ResourceTemplate () { I2cSerialBus (0, ControllerInitiated, 400000, AddressingMode7Bit,
          "\\_SB.PC00.I2C4", 0x00, ResourceConsumer, DEV4,) })
          CreateWordField (IIC4, DEV4._ADR, DAD4)
          Store (Arg0, DAD4)
          Return (IIC4) }
        Case(5) { Name (IIC5 , ResourceTemplate () { I2cSerialBus (0, ControllerInitiated, 400000, AddressingMode7Bit,
          "\\_SB.PC00.I2C5", 0x00, ResourceConsumer, DEV5,) })
          CreateWordField (IIC5, DEV5._ADR, DAD5)
          Store (Arg0, DAD5)
          Return (IIC5) }
        Default {Return (0)}
      }
    }

    //
    // Create I2C Bus Resource descriptor for _CRS usage
    // Arg0 - I2C bus address of the connection (Slave Address)
    // Returns buffer with 'I2cSerialBus' resource descriptor
    //
    Method (VIIC, 1, Serialized) {
      Name (VIC0, ResourceTemplate () {
          I2cSerialBus (0, ControllerInitiated, 400000,
              AddressingMode7Bit, "\\_SB.PC00.XHCI.RHUB.HS04.VI2C",
              0x00, ResourceConsumer, VDEV,)
      })
      CreateWordField (VIC0, VDEV._ADR, DADR)
      Store (Arg0, DADR)
      Return (VIC0)
    }

    //
    // Create Interrupt Resource descriptor for _CRS usage
    // Arg0 - GPIO Pad used as Interrupt source
    // Arg1 - Edge (1) or Level (0) interrupt triggering
    // Arg2 - Active Level: High (1) or Low (0)
    // Returns buffer with 'Interrupt' resource descriptor
    //
    Method (INTB, 3, Serialized) {
      Name (INTR, ResourceTemplate () { Interrupt (ResourceConsumer, Level, ActiveLow, ExclusiveAndWake,,,INTI) {0} })
      // Update APIC Interrupt descriptor
      CreateDWordField (INTR, INTI._INT, NUMI) // Interrupt Number
      Store (INUM(Arg0), NUMI)
      CreateBitField (INTR, INTI._HE, LEVI) // Level or Edge
      Store (Arg1, LEVI)
      CreateBitField (INTR, INTI._LL, ACTI) // Active High or Low
      Store (Arg2, ACTI)

      Return (INTR)
    }

  } // END Scope(\_SB.PC00)

  Include ("Pch.asl")  // Not in this package. Refer to the PCH Reference Code accordingly
  Include ("LpcB.asl")
  Include ("Platform.asl")
  Include ("Cpu.asl")
  Include ("PciDrc.asl")
  Include ("Video.asl")
  Include ("FwuWmi.asl")
  Include ("Gpe.asl")
  Include ("Pep.asl")
  Include ("Connectivity.asl")
  Include ("PchRpPxsxWrapper.asl")
  Include ("SerialIoDevices.asl")
  Include ("SerialIoTimingParametersEmbedded.asl")
  Include ("HidPlatformEventDev.asl")
  Include ("HIDWakeDSM.asl")
  Include ("PinDriverLib.asl")

  If(LEqual(CVFS,1)) {
    Include("Cvf.asl")
  }

  If (LAnd(LNotEqual(PSWP, 0), LEqual(RPNB, 0x05))) {
    Scope(\_SB.PC00.RP05) {
      Method (PPRW, 0) {
        Return (GPRW (GGPE (PSWP), 4))
      }
    }
  }

  If (LOr(LAnd(LNotEqual(PSW2, 0), LEqual(RPN2, 0x08)) ,LAnd(LNotEqual(WLWK, 0), LEqual(WLRP, 0x08)))) {
    Scope(\_SB.PC00.RP08) {
      Method (PPRW, 0) {
        If (LAnd(LNotEqual(PSW2, 0), LEqual(RPN2, 0x08))) {
          Return (GPRW (GGPE (PSW2), 4))
        }
        If (LAnd(LNotEqual(WLWK, 0), LEqual(WLRP, 0x08))) {
          Return (GPRW (GGPE (WLWK), 4))
        }
        Return (GPRW (GGPE (PSW2), 4))
      }
    }
  }

  If (LAnd(LNotEqual(WLWK, 0), LEqual(WLRP, 0x03))) {
    Scope(\_SB.PC00.RP03) {
      Method (PPRW, 0) {
        Return (GPRW (GGPE (WLWK), 4))
      }
    }
  }

  If (LAnd(LNotEqual(WWKP, 0), LEqual(WWRP, 0x04))) {
    Scope(\_SB.PC00.RP04) {
      Method (PPRW, 0) {
        Return (GPRW (GGPE (WWKP), 4))
      }
    }
  }

  If (LAnd(LNotEqual(WWKP, 0), LEqual(WWRP, 0x09))) {
    Scope(\_SB.PC00.RP09) {
      Method (PPRW, 0) {
        Return (GPRW (GGPE (WWKP), 4))
      }
    }
  }

  Name(\_S0, Package(4){0x0,0x0,0,0}) // mandatory System state
  if(SS1) { Name(\_S1, Package(4){0x1,0x0,0,0})}
  if(SS3) { Name(\_S3, Package(4){0x5,0x0,0,0})}
  if(SS4) { Name(\_S4, Package(4){0x6,0x0,0,0})}
  Name(\_S5, Package(4){0x7,0x0,0,0}) // mandatory System state

  Method(PTS, 1) {        // METHOD CALLED FROM _PTS PRIOR TO ENTER ANY SLEEP STATE
    If(Arg0)              // entering any sleep state
      {
      }
    }
    Method(WAK, 1) {      // METHOD CALLED FROM _WAK RIGHT AFTER WAKE UP
  }
}// End of ASL File
