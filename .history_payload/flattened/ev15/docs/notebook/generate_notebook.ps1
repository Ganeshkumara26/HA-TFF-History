$notes = @(
    @{
        date = "2026-01-08"; content = "Today: Wrote the initial parser state machine. Failed simulation horribly.`n`nReason: Forgot that Ethernet frames arrive MSB first but AXI maps them LSB first in byte order. Need to write an endian conversion macro.`n`nTomorrow: Fix the byte swapping."
    },
    @{
        date = "2026-01-29"; content = "Today: Tried to run the unpipelined Cuckoo Matcher in Vivado.`n`nStatus: Disastrous. Synthesis crashed my laptop. When I ran it on the lab computer, the logic depth was 14 levels. Timing is utterly destroyed.`n`nTomorrow: Rip it out and add pipeline registers. Latency will increase, but it's the only way."
    },
    @{
        date = "2026-03-14"; content = "Today: Finally broke the SNN adder chain into two cycles.`n`nStatus: TIMING CLOSED! WNS is positive (+0.517ns). `n`nObservation: I had to delay the datapath by 1 cycle to keep it aligned with the new 5-cycle SNN. It worked perfectly in simulation.`n`nTomorrow: Start writing the final report."
    }
)

foreach ($n in $notes) {
    Set-Content -Path "d:\Downloads\ha_tff\Engineering_History\11_Lab_Notebook\$($n.date).md" -Value $n.content
}
