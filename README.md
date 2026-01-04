# Signal Processing Project
---

## Overview

This project addresses two signal processing problems involving non-ideal sampling and audio event detection. 

### 1. Non Ideal Sampling

The first part focuses on practical deviations from ideal Nyquist sampling for band-limited signals. Two non-ideal sampling scenarios are considered:

#### a) Sampling Time Delay

Sampling does not occur exactly at integer multiples of the sampling interval. Each sample is affected by a small, known but random timing offset. A reconstruction method is developed to estimate the original uniformly sampled signal while minimizing reconstruction error. Performance was measured as a function of the maximum timing deviation parameter, K.

#### b) Missing Samples

The sampling instant has no error, but the sample may be missing with a certain probability.
For both these scenarios a method was developed to estimate the originial signal with least minimal error. An estimation method is proposed to recover the original signal from incomplete data. Here performance was measured as a function of the missing sample probability, p.

### 2. Drum Beat Detection

The second problem required analysis of 4 different audio files of drum beats. The objectives were to identify the time stamps of the hits and to classify the drum beat based on the type of the drum instrument.

---

## Method Developed

### Non Ideal Sampling

#### a) Sampling Time Delay

The method extends sinc-based reconstruction by accounting for known timing errors in the sampling instants and estimating each uniform sample using nearby non-uniform samples.

#### b) Missing Samples

The method followed is the Paoulis-Gerchberg process. 
First, the reconstruction fills in the missing samples with a rough inital estimate. The signal is then repeatedly refined by removing frequency components that lie outside the known bandwidth. Once this is done, the original available components are restired in their original positions. This process is repeated multiple times until the signal converges. 

### Drum Beat Detection




---

## Results Obtained


---

## Contributions
This project was collaboratively developed by:

- [Sukeerthi Kattamuri](https://www.linkedin.com/in/sukeerthi-kattamuri-5394a1266)
- Chandralekhya
- Padmanjali


