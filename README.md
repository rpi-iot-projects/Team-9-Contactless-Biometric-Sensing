# Contactless Biometric Sensing

A radar-based real-time contactless heart and breathing rate monitor that can be wirelessly monitored on a live website.

## Table of Contents
- [Overview](#overview)  
- [Hardware Components](#hardware-components)  
- [Software and Dependencies](#software-and-dependencies)  
- [Usage](#usage)
- [Results and Demonstration](#results-and-demonstration)  

## Overview

This project aims to develop a live-updating, contactless biometric sensor that can send real-time updates to the user. It intends to create a solution to the limited accessibility and real-time updates of home-use healthcare devices. A radar detects the user's biometrics (heart and breathing rate) and sends it to a live-updating website, which can send alerts if the heart rate is displaying abormal behaviour.

## Hardware Components

- [TinyRad](https://www.analog.com/en/resources/evaluation-hardware-and-software/evaluation-boards-kits/eval-tinyrad.html) (radar)

## Software and Dependencies

- MATLAB (for simulation and TinyRad code)
- HTML & JavaScript

## Usage

### To run simulation:
- Open MATLAB
- Download and run either breathingrate_simulation.mlx or heartrate_simulation.mlx

### To run on TinyRad:
- Plug in the TinyRad device onto the computer
- Download tinyrad.m
- Run file on MATLAB

## Results and Demonstration

### Breathing Rate FFT Simulation Results:
<img src="https://github.com/user-attachments/assets/5de00183-884e-43ce-b194-958d91b22f84" alt="breathing rate is 11.7 bpm" style="width:50%; height:auto;">

### Heart Rate FFT Simulation Results:
<img src="https://github.com/user-attachments/assets/c4fd24f6-4f10-4228-a8d6-05dd72dc92a5" alt="heart rate is 58.6 bpm" style="width:50%; height:auto;">

### TinyRad Results:
<img src="https://github.com/user-attachments/assets/dd30e4f8-1a24-48a2-bdc9-a1460bd39c24" alt="breathing and heart rate pattern" style="width:50%; height:auto;">

### Website Display:
<img src="https://github.com/user-attachments/assets/a4709e4a-ef29-46ba-8364-ea60f012c8d3" alt="breathing and heart rate pattern" style="width:50%; height:auto;">
