# Frontend:

- Add panel to the right with menu listing pages with documentation
- Add some standard footer
- Add minimal navbar with site name, and one toggle button from each side
- Add panel on the right side. Within this panel, add a bordered panel with listed tips for using the site 5. Format the result text. For each line written in M2, the result usually contains 3 parts, looking like that:
```
i1 : -- Macaulay2 example
     R = QQ[x,y,z]

o1 = R

o1 : PolynomialRing

i2 : I = ideal(x^2 + y^2, z^2)

             2    2   2
o2 = ideal (x  + y , z )

o2 : Ideal of R

i3 : I

             2    2   2
o3 = ideal (x  + y , z )

o3 : Ideal of R

i4 : exit
```
We want to format this text so that:
the 'i6 : ' part represents our input. It should be rendered as the code snippet from a terminal and the `i3` part should be rendered as it was line number;
the 'o6 = ' part represents the output value. It shouldf be rendered not as a code snippet and the algebraic expressions should be rendered in TeX math mode;
the 'o6 : ' part represents the output type. It should be rendered on the right side of the output, not in a different line, and the prefix should be removed. It should be distinc from the output value, being in some box with different background color.

- Both text areas should have bigger sizse, both width and height
