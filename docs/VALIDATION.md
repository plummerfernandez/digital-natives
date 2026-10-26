# Validation — 26 October 2026

14 Node regression tests passed on the copied original vase and synthetic geometry.

The browser regression suite passed in headless Google Chrome with WebGL: both views rendered; all 36 colour algorithms and exposed transformations ran; selection, undo/redo, session round-trip, original notes import, uploaded OBJ, binary colour STL/VRML/OBJ/PNG downloads and mobile layout were exercised. No JavaScript page errors were recorded. Desktop screenshots of both tools were visually inspected.

This establishes functional browser operation, not equivalence to the original Java implementation. See PORTING.md for fidelity limits.
