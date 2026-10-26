// Labels describe the actual legacy formulas; P numbers remain stable in saved files.
const gain = [
  "Red rise",
  "Green rise",
  "Blue rise",
  "Red base",
  "Green base",
  "Blue base",
  "Colour noise",
  "Gradient compression",
];
const ends = [
  "Red 1",
  "Green 1",
  "Blue 1",
  "Red 2",
  "Green 2",
  "Blue 2",
  "Colour noise",
  "Mapping offset",
];
const unused = "Unused";
export function colourLabels(id) {
  id = Number(id);
  let labels = [...ends];
  let note =
    "Colour 2 maps to the start of the range; colour 1 maps to its end. The range follows the algorithm’s height, radius or face-area mapping.";
  if ([2, 3, 5, 6, 7, 8, 9, 10, 25, 26].includes(id)) {
    labels = [...gain];
    note =
      "Base values set the starting colour. Rise values add red, green or blue across the gradient; they are amounts, not a second colour.";
  }
  if (id === 0) {
    labels = Array(8).fill(unused);
    note = "Solid white. This algorithm has no adjustable parameters.";
  }
  if (id === 1) {
    labels = Array(8).fill(unused);
    labels[6] = "Colour noise";
    note =
      "Random red and green with a bright blue channel. Colour noise varies the channels together.";
  }
  if ([5, 6, 8, 9, 10, 11, 12, 14].includes(id)) labels[7] = unused;
  if (id === 7) {
    labels.splice(
      3,
      3,
      "Red subtraction",
      "Green subtraction",
      "Blue subtraction",
    );
    note =
      "Rise values build the gradient; subtraction values darken each colour channel.";
  }
  if ([8, 16, 17, 20, 21, 22, 23, 24].includes(id))
    labels[6] = "Noise frequency";
  if (id === 9) {
    labels[6] = "Noise / swap threshold";
    note =
      "P7 changes both colour noise and face-swapping probability. Increasing it adds noise but reduces swapping.";
  }
  if (id === 11) {
    labels = [
      "Hue base",
      "Hue rise",
      "Saturation base",
      "Saturation rise",
      "Brightness base",
      "Brightness rise",
      "Brightness noise",
      unused,
    ];
    note =
      "Hue, saturation and brightness each have a starting value and a height-dependent increase.";
  }
  if (id === 12) {
    labels = [
      "Hue 1",
      "Hue 1 rise",
      unused,
      "Hue 2",
      "Hue 2 rise",
      "Saturation 2",
      "Brightness noise",
      unused,
    ];
    note =
      "Blends two hue gradients equally. The first has fixed saturation and brightness; the second has adjustable saturation and brightness noise.";
  }
  if ([30, 31].includes(id)) {
    labels = [
      "Red radial end",
      "Green radial end",
      "Blue radial end",
      "Red radial start",
      "Green radial start",
      "Blue start / red top",
      "Green top",
      "Blue top",
    ];
    note =
      "Combines radial and vertical gradients. P6 is shared: it sets both the radial blue start and the final red value.";
    if (id === 31)
      note += " This reverse variant also adds fixed random noise.";
  }
  if (id === 28) {
    labels[6] = unused;
    note =
      "Red follows height; green and blue follow radius. Colour 2 is the start and colour 1 the end.";
  }
  if (id === 32) {
    labels = [
      "Red top",
      "Green top",
      "Blue top",
      "Red middle",
      "Green middle",
      "Blue middle",
      unused,
      "Base brightness",
    ];
    note =
      "A three-stop vertical gradient: a grey base, an RGB middle and an RGB top.";
  }
  if ([33, 34].includes(id)) {
    labels = [
      "Red top",
      "Green top",
      "Blue top",
      "Red middle",
      "Green middle",
      "Blue middle",
      "Red base",
      "Blue base",
    ];
    note =
      "A three-stop vertical gradient. The bottom green channel is fixed at zero; P7 and P8 set bottom red and blue.";
  }
  if (id === 35) {
    labels = [
      "Hue 1",
      "Hue 2",
      "Saturation 1",
      "Saturation 2",
      "Brightness 2",
      unused,
      "Colour noise",
      "Gradient start (%)",
    ];
    note =
      "Blends from colour 2 at the bottom to colour 1 at the top. Colour 1 has fixed full brightness.";
  }
  return { labels, note };
}
export function formLabels(operation) {
  const pairs = {
    wave: [
      "Wave amplitude",
      "Twist offset",
      "Wave uses S1 to set sideways displacement; S2 is only used by the separate Twist tool.",
    ],
    cavity: [
      "Cavity growth",
      "Twist offset",
      "S1 expands the randomly selected hole in steps of ten. S2 does not affect the cavity.",
    ],
    cup2: [
      "Cup scale step",
      "Cup phase",
      "S2 shifts the sine profile. The original S1 setting changes scale only at 100.",
    ],
    spikes: [
      "Spike length",
      "Twist offset",
      "S1 controls spike length. Reverse direction changes whether spikes point inward or outward.",
    ],
    perlin: [
      "Noise strength",
      "Noise frequency",
      "Strength controls displacement; frequency controls the size of the noise pattern.",
    ],
    twist: [
      "Axis tilt",
      "Axis offset",
      "S1 and S2 position the purple twist axis. Reverse direction changes the rotation direction.",
    ],
    bellbase: [
      "Bell strength",
      "Bell frequency",
      "Controls the strength and oscillation of the bell-shaped base.",
    ],
    scaleX: [
      "Scale amount",
      "Twist offset",
      "S1 sets the scale factor, from 0.2× to 2×.",
    ],
    scaleY: [
      "Scale amount",
      "Twist offset",
      "S1 sets the scale factor, from 0.2× to 2×.",
    ],
    scaleZ: [
      "Scale amount",
      "Twist offset",
      "S1 sets the scale factor, from 0.2× to 2×.",
    ],
    scaleAll: [
      "Scale amount",
      "Twist offset",
      "S1 sets the scale factor, from 0.2× to 2×.",
    ],
  };
  const [s1, s2, note] = pairs[operation] || [
    "Twist tilt",
    "Twist offset",
    "This operation does not use S1/S2. They remain available to position the separate Twist tool’s purple axis.",
  ];
  return {
    labels: ["Upper cut (%)", "Lower cut (%)", s1, s2],
    note:
      operation === "printerSlip"
        ? "Upper cut sets the printer-slip height. S1/S2 only affect the separate Twist tool."
        : note,
  };
}
