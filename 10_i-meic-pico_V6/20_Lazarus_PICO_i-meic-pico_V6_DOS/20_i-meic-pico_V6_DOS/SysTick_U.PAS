unit SysTick_U;

{$mode objfpc}

interface


uses
  pico_multicore_c,
  pico_timer_c,
  pico_gpio_c;

var
  stack_bottom_core1 : uint32=$40000;


  procedure Start_SysTick;



implementation



{
|----------$42000------------|
|                            |
|                            |
|       stack CORE 0         |  4096 bytes
|                            |
|                            |
|----------$41000------------|
|                            |
|                            |
|       stack CORE 1         |  4096 bytes
|                            |
|                            |
|----------$40000------------|
}

  // SysTick auf 55ms eingestellt
  procedure core1_entry;
  begin
    repeat                                                // blink the core 1 LED
     gpio_put(TPicoPin.NMI_80,false);
     busy_wait_us_32(25000);
     gpio_put(TPicoPin.NMI_80,true);
     busy_wait_us_32(29000);
    until 1=0;
  end;



  procedure Start_SysTick;
  begin

    multicore_reset_core1;                                // first stop core 1

    // NMI_80 - Ausgang und Low (InAktiv)
    gpio_init(TPicoPin.NMI_80);
    gpio_set_dir(TPicoPin.NMI_80,TGPIODirection.GPIO_OUT);
    gpio_put(TPicoPin.NMI_80,false);

    multicore_launch_core1_with_stack(@core1_entry,@stack_bottom_core1,$1000);      // launch core1

  end; // Start_SysTick




end.

