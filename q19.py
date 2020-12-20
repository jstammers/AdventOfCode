
import re

rules_inp, messages_inp = ''.join(open('data/q19.txt').readlines()).split('\n\n')
messages = messages_inp.split('\n')
rules = dict()
for rule in rules_inp.split('\n'):
    i, r = rule.split(': ')
    rules[int(i)] = r.strip('\"')

def evaluate(i):
    if rules[i] in 'ab':
        return rules[i]
    parts = rules[i].split(' | ')
    for j, p in enumerate(parts):
        parts[j] = '(' + ''.join(evaluate(int(n)) for n in p.split()) + ')'
    return '(' + '|'.join(parts) + ')'

c1, c2 = 0, -1
i = 2
while c1 != c2:
    rules[8] = '42' + (' |' if i > 2 else '') + ' |'.join(' 42'*j for j in range(2, i))
    rules[11] = '42 31' + (' |' if i > 2 else '') + ' |'.join(' 42'*j + ' 31'*j for j in range(2, i))
    expr = evaluate(0)
    counter = 0
    for msg in messages:
        if re.match(f'^{expr}$', msg):
            counter += 1
    c2 = c1
    c1 = counter
    i += 1
print(c1)