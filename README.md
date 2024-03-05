# NVMe offload scripts

This repo contains scripts to help configure and monitor NVMe offload on a system.

## aRFS.sh

Enable aRFS on the interface given.

Example:

    $ ./aRFS.sh eth0

## set_irq_affinity.sh

Set the CPU where IRQ handlers are run for each IRQ of the interface given.
Mapping is done linearly: first RX queue interrupts mapped on CPU 0, second to CPU 1, and so on.

Example:

    $ ./set_irq_affinity.sh eth0

## pktstat

Monitor offload rates on the interface given. Updates every second.

Prints the current bandwidth in Gigabit/s, offload rate by packet (in %), offload rate by byte.

The script requires access to the Linux kernel git repo from which the kernel was built (via `LINUX` environement variable).

Example:

    $ LINUX=~/linux-git ./pktstat eth0
    RX 175.1 Gbps    95% off.bytes   100% off.pkts TX   0.2 Gbps     0% off.bytes     0% off.pkts
    RX 173.9 Gbps    95% off.bytes   100% off.pkts TX   0.2 Gbps     0% off.bytes     0% off.pkts
    RX 177.5 Gbps    94% off.bytes    99% off.pkts TX   0.2 Gbps     0% off.bytes     0% off.pkts
    RX 175.1 Gbps    95% off.bytes   100% off.pkts TX   0.2 Gbps     0% off.bytes     0% off.pkts
    RX 174.3 Gbps    95% off.bytes   100% off.pkts TX   0.2 Gbps     0% off.bytes     0% off.pkts
    RX 173.3 Gbps    94% off.bytes    99% off.pkts TX   0.2 Gbps     0% off.bytes     0% off.pkts


## irqstats

Monitor IRQ fire rates per CPU, and CPU usage. Updates every second.
See `--help` for complete documentation.

Useful to check for CPU alignement issues and ensure proper configuration.

Example:

    $ irqstats -m100 --cpu --cpu-usage --irq -pp
    TOP IRQ FIRED                                                           | TOP CPU IRQ HANDLER                                                     | TOP CPU USAGE
    IRQ 217    mlx5_comp6@pci:0000:2b:00.0:  237546 +50844 (CPU5  +50844 )  | CPU5 :  237546 +50844 (IRQ217 +50844 CAL +77 RES +40 )                  | CPU5 :  91%  sys:32% sirq:58%
    IRQ 215    mlx5_comp4@pci:0000:2b:00.0:  233989 +48200 (CPU3  +48200 )  | CPU3 :  233989 +48200 (IRQ215 +48200 CAL +37 RES +5 )                   | CPU3 :  89%  sys:28% sirq:59%
    IRQ 216    mlx5_comp5@pci:0000:2b:00.0:  227311 +46886 (CPU4  +46886 )  | CPU4 :  227311 +46886 (IRQ216 +46886 CAL +80 RES +27 )                  | CPU0 :  86%  sys:29% sirq:56%
    IRQ 192    mlx5_comp1@pci:0000:2b:00.0:  225716 +46310 (CPU0  +46310 )  | CPU0 :  225716 +46310 (IRQ192 +46310 CAL +43 RES +15 )                  | CPU1 :  84%  sys:28% sirq:55%
    IRQ 214    mlx5_comp3@pci:0000:2b:00.0:  225659 +45794 (CPU2  +45794 )  | CPU2 :  225659 +45794 (IRQ214 +45794 CAL +59 RES +21 )                  | CPU7 :  83%  sys:29% sirq:53%
    IRQ 219    mlx5_comp8@pci:0000:2b:00.0:  225071 +46953 (CPU7  +46953 )  | CPU7 :  225071 +46953 (IRQ219 +46953 CAL +94 RES +19 )                  | CPU4 :  81%  sys:23% sirq:58%
    IRQ 213    mlx5_comp2@pci:0000:2b:00.0:  221870 +45372 (CPU1  +45372 )  | CPU1 :  221870 +45372 (IRQ213 +45372 CAL +81 RES +18 )                  | CPU2 :  78%  sys:24% sirq:53%
    IRQ 218    mlx5_comp7@pci:0000:2b:00.0:  221431 +45777 (CPU6  +45777 )  | CPU6 :  221431 +45777 (IRQ218 +45777 CAL +60 RES +22 )                  | CPU6 :  78%  sys:22% sirq:54%
    CAL           Function call interrupts:    3504 +598 (CPU 0-8,33-34,51) | CPU21:    2664 +571 (IRQ191 +571 )                                      |
    IRQ 191   mlx5_async0@pci:0000:2b:00.0:    2664 +571 (CPU21 +571 )      |                                                                         |
    TLB                     TLB shootdowns:    1273                         |                                                                         |
    RES            Rescheduling interrupts:     929 +167 (CPU 0-7)          |                                                                         |

In this example, top IRQs for each CPU are their respective RX queue.
Inter-processor calls (CAL) or CPU migrations/rescheduling (RES) are kept low.
The system is properly aligned.
