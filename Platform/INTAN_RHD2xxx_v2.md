

## Registros de configuración y estado de la transmisión serie:

### **TX_CTL** (@0x2F, slv_reg47):

```vhdl
slv_reg47 <= slv_reg47(31 downto 3) & s_tx_rst_en & s_tx_en_int & s_tx_en;
```


```wavedrom
{reg: [
  {bits: 1,  name: 'tx_en', type: 1},
  {bits: 1,  name: 'tx_ent_int', type: 2}, 
  {bits: 1,  name: 'tx_rst_en', type: 3},
  {bits: 10,  name: 't_bit', type: 4},
  {bits: 19,  name: 'reserved', },
],
 config:{bits: 32, lanes: 4}
}

```

- **tx_en**: Habilita/Deshabilita la transmisión serie. Escribir '1' para hacer el cambio. 
- **tx_en_int**: Habilita/Deshabilita la interrupción de la transmisión serie. Escribir '1' para hacer el cambio.
- **tx_rst_en**: Habilita/Deshabilita el reset de la transmisión serie. Escribir '1' para hacer el cambio.
- **t_bit**: Tiempo de bit para la transmisión serie. Representado en número de ciclos de reloj por bit. Valor por defecto = 95.

### **TX_CTL** (@0x30, slv_reg48):


```vhdl
p_tx_reg48:process(S_AXI_ACLK, S_AXI_ARESETN)
    begin
        if (S_AXI_ACLK'event and S_AXI_ACLK = '1') then
            if (S_AXI_ARESETN = '0') then
                slv_reg48 <= (others => '0');
            else 
                slv_reg48 <= slv_reg48(31 downto 6) & s_tx_enable & s_tx_overrun & s_tx_int & s_tx_fifo_full & s_tx_fifo_empty & not(s_tx_nbsy);
            end if;
        end if;
    end process p_tx_reg48;
```

```wavedrom
{reg: [
  {bits: 1,  name: 'tx_bsy', type: 1},
  {bits: 1,  name: 'tx_fifo_empty', type: 2}, 
  {bits: 1,  name: 'tx_fifo_full', type: 3},
  {bits: 1,  name: 'tx_int', type: 4},
  {bits: 1,  name: 'tx_tx_overrun', type: 5},
  {bits: 26,  name: 'reserved', },
],
 config:{bits: 32, lanes: 4}
}
```

- **tx_bsy**: Indica que la transmisión serie está ocupada. '1' ocupado, '0' libre.
- **tx_fifo_empty**: Indica que el FIFO de transmisión está vacío. '1' vacío, '0' hay palabras almacenadas.
- **tx_fifo_full**: Indica que el FIFO de transmisión está lleno. '1' lleno, '0' espacio disponible.
- **tx_int**: Indica que la interrupción de la FIFO está habilitada. '1' interrupción habilitada
- **tx_overrun**: Indica que ha habido un error en la transmisión serie. Cuando la Fifo se llena en mitad de una serie de canales, se activa este bit y se deja de transmitir el grupo de canales. Se mantiene en alto hasta que se transmite el siguiente grupo.
  
