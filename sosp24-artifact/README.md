# Colloid Artifact

This directory contains scripts and instructions for running the experiments from our SOSP'24 paper.

## Server Access: A Note for Artifact Evaluators

For artifact evaluation, we will provide evaluators (secure and anonymous) access to a server with specifications matching the evaluation setup used in the paper. To reduce evaluator burden, all the necessary systems and tools will be pre-compiled and configured on the server so that evaluators can directly start running experiments.

**We request the evaluators to reserve time-slots through this [calendar](https://www.when2meet.com/?26030139-uGeiv), and send us a note on hotCRP once you have done so. We will make sure the server is available and accessible during each time-slot. We request evaluators to mark themselves as Reviewer A/B/C, etc., to preserve anonymity. Estimated times for both Testing Functionality and Reproducing Results are provided below. Also please avoid selecting timeslots that have already been reserved (marked in green on the calendar).**

Access to the server will be facilitated through a secure VPN. We will share VPN details and ssh credentials through HotCRP once the evaluation period starts.

## Testing functionality (Estimated time: 30 mins)

We provide a quick start guide to run a simple experiment with each of the systems to test that they are functional. Detailed instructions for each system are provided below (Similar flow will be used later for reproducing the paper results. We recommend that reviewers try this out to gain familiarity with the setup):

* For, HeMem + colloid, see [here](hemem/test.md)
* For, TPP + colloid, see [here](tpp/test.md)


## Reproducing results (Estimated time: 14 hrs)

### Experiments

Experiments described in the paper can be run using the scripts provided in this repository.

We recommend running experiments in the order of systems (i.e., run all experiments for one system before moving to the next system). This is because switching between systems is time consuming---it requires changing the kernel and thus rebooting the server.  The following table summarizes the different systems/configurations evaluated in the paper and the directory containing the respective experiment scripts. The READMEs in the respective directories provide detailed instructions on how to run all the experiments for each system.

| System / configuration | Related Figures |	Directory | Estimated time |
| :-------------- | :--------------- | :----------------- | :------------------ |
| HeMem (+colloid)   |     	Figure 4, 6, 7, 8  |      	[hemem](hemem)   | 3.5 hrs |      
|  TPP w/ THP (+colloid) |  	Figure 4, 6, 8   |     [tppthp](tppthp)  |   5.5 hrs  |
|   TPP (+colloid)       | 	Figure 4, 6, 8   |     [tpp](tpp)   |  5 hrs    |  

(Note: Figure 1 is a subset of Figure 4; Figures 2 and 5 are auxiliary figures used to explain Figures 1 and 4 experiments---they do not correspond to standalone experiments, and are therefore omitted)


**Tip:** Since many of the individual experiments take on the order of several minutes to complete, we strongly recommend using `tmux`/`screen` to avoid experiments from being disrupted by ssh getting disconnected. For a crash course on `tmux` see [here](tmux-usage.md). 
