clear; clc; close all

initializeWecSim

tg = slrealtime();

connect(tg);

slbuild('LUPAsimTBSD');

load(tg, 'LUPAsimTBSD');

start(tg);