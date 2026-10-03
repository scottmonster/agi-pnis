







Glossary skill:
- contains definitions for words and/or phrases
- used when asked to add defintion, or a definitiion is explicitly made by user
- maintains an entry in AGENTS.md containing a list of defined words and phrases (but not their definitions. definitions should be kept in the glossary)



















agents are using the `/home/scott/Documents/agi-pnis/gov-lab/.agents/skills/md` for absolutely EVERY markdown creation or edit. which isn't horrible but it causes the audit to run frequently. How can we help prevent that? if we wanted to put a gate on it,  what do you think we can do about that?



let's discuss
see: /home/scott/Documents/agi-pnis/gov-lab/.agents/records/failures

1. we want the records to be indexed with three digit zero-padded numeric prefixes so the last records can be easily identified
2. the corrective action isn't exactly what we want. it is good but maybe we should add a required "rule" to the description. we would want the rule to stay generic and not too specific `/home/scott/Documents/agi-pnis/gov-lab/.agents/skills/md/src/operations/audit.md` implements this for the scope of it's skill. we would want something simlar in the corrective action porttion of the schema
3. We need to make this more explicit but also more generic `description: Use when a governing material judgement is established or materially updated, or a detected material failure requires a record. Do not use for active discussion or tentative analysis.` we shouldn't use our skill specific terms because agents will not have the context of what "governing material judgement", "materially updated", or "material failure requires a record" actually means.



complete:

1. we should also make the update records two digit zero-padded numeric indexed as decimals reverencing the original FR/JR. so that an updte record for 001-[FR|JR]-whatever.md would then become 001.00-[FUR|JUR]-some-update.md and then the next one would be 001.01-[FUR|JUR]-some-other-update.md and so on
2. yes. do this
3. yes plain language. don't change model invocation
4. you said "There is also a fourth issue: the current episode skill is implicitly invokable, so it can be selected automatically. Its frontmatter is disable-model-invocation: false, and its metadata allows implicit invocation. That conflicts with the goal of avoiding unnecessary activation."... we want the skill to be automaticall activated, but we just don't want it over used.




Error creating chat
error creating thread: Fatal error: Failed to initialize session: failed to load AGENTS.md instructions for environment `local`: fs sandbox helper failed with status exit status: 1: bwrap: Exceeded maximum number of arguments 9000