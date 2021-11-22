# LAB 2


           Selector  +--------------+         +-----------+
          ---------->|              |         |           |
                     | Segmentation |         |  Paging   |
Software             |              |-------->|           |---------->  RAM
            Offset   |  Mechanism   |         | Mechanism |
          ---------->|              |         |           |
                     +--------------+         +-----------+
            Virtual(logic)            Linear                Physical



## Questions

### Question in part 2

Assuming that the following JOS kernel code is correct, what type should variable x have, `uintptr_t` or `physaddr_t`?
```
	mystery_t x;
	char* value = return_a_pointer();
	*value = 10;
	x = (mystery_t) value;

```
Answer: `uintptr_t`
