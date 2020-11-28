# Reinforcement Learning using Deep Q Learning on Contra

This repository is about implementing the reinforcement learning algorithm Deep Q Learning on the game of Contra. To interact with Contra, we are using OpenAI- Gym.

## Installation

### Installation Requirements
We created an virtual environment to work with the project with all the libraries installed. To activate the virtual environment on python 3.6,
The virtual environment is installed in folder /env that has all the supporting libraries installed.
```
source env/bin/activate
```
### To run random Agent using Gym-Retro

```
pip install gym-retro
python -m randomAgent --game ContraForce-Nes                                                                                              
```

We tried gym-retro to make the nes environment for the contra for openAI env. Gym retro helps to make the env from the NES ROM file. But that approach didn't work so we tried with tf-agent from the tensorflow library, it had inconsistency to handle the nes file wrapper other than available in the openAI gym itself. We were succcessfully able to make a tf-agent DQN on Cartpool game with the video. 

So, to solve this issue we wrapped the env around gym-contra library with the 4, ,7 ,10 actions types : RIGHT ONLY, SIMPLE MOVEMENT and COMPLEX MOVEMENT. 

After this, we were able to run it using DQN networks.

we used Keras, Tensorflow to make the DQN network. 

The policies are Boltmannz, Epislon and Annealing.

We found that Annealing was the best for rewards but the epislon greedy was good for going further in the level.
