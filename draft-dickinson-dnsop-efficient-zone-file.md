%%%
    Title = "Considerations for efficiently parsing zone files"
    abbrev = "Making zone file parsing easier"
    docName= "draft-dickinson-dnsop-efficient-zone-file-00"
    ipr = "trust200902"
    area = "Internet"
    workgroup = "dnsop"
    keyword = ["DNS"]
    [pi]
    toc = "yes"

    [seriesInfo]
    status = "standard"
    name = "Internet-Draft"
    value = "draft-dickinson-dnsop-efficient-zone-file-00"
    stream = "IETF"
    [[author]]
    initials="J."
    surname="Dickinson"
    fullname="John Dickinson"
    organization = "Sinodun IT"
      [author.address]
      email = "jad@sinodun.com"
%%%

.# Abstract

This document discusses the challenges involved in parsing the full
zone file text format defined in [RFC1035] efficiently. It proposes a reduced
(backwards compatible) format that allows a highly optimized token based
parsing logic to be used. Implementations supporting this optimized parsing can
preferentially use it when reading zone files to greatly increasing the speed
at which a large zone file can be read.

{mainmatter}


# Introduction

The zone file format defined in [@!RFC1035] contains a number of features that
are largely intended to make human editing and reading of zone files easier.
However, these present various challenges to efficient machine parsing of a
zone file that utilizes such features. In particular, it requires all the RRs
to be read in the context of the entire zone data which adds significant
overhead and complexity. See [@simdzone] and [@nsd]. 

There are also non-standard features such as $GENERATE [@bind9].

This approach can mean that the time taken in practice to parse very large zone files
can become a significant operational issue [references].

This document proposes a simplified, reduced format (a subset of the existing
syntax) which is aligned with a high performance token based parsing logic, 
making use of CPU SIMD extensions. Such logic has been
shown to be extremely efficient [references...] and in experimental code has been
shown to increase the data throughput of parsing a zone file by * [references].

The goal of this document is to describe this reduced format, called 'fast zone
file format' or just 'fast format', so that implementations can develop
interoperable readers and writers. Based on configuration options
implementations that support an optimized parser can then preferentially
attempt to use that when reading a zone file.

TODO: More background. Also fill in references and data above


# Example Zone
This zone file is based on one from [@nsd]
~~~txt
1  $ORIGIN example.com. ; 'default' domain as FQDN for this zone
2  $TTL 86400 ; default time-to-live for this zone
3  
4  example.com.   IN  SOA     ns.example.com. noc.dns.icann.org. (
5          2020080302  ;Serial
6          7200        ;Refresh
7          3600        ;Retry
8          1209600     ;Expire
9          3600        ;Negative response caching TTL
10 )
11 
12 ; The nameserver that are authoritative for this zone.
13                                 NS      example.com.
14 
15 ; these A records below are equivalent
16 example.com.    A       192.0.2.1
17 @                               A       192.0.2.1
18                                 A       192.0.2.1
19 
20 @                               AAAA 2001:db8::3
21 
22 ; A CNAME redirect from www.exmaple.com to example.com
23 www                             CNAME   example.com.
24 
25 mail                    MX      10      example.com.
26 
27 1.2.0.192.in-addr.arpa". PTR example.com.
28
29 svc4.example.com.  7200  IN SVCB 3 svc4.example.com. (
30     alpn="bar" port="8004" ech="..." )
~~~
Figure: A zone file that illustrates some of the issues with parsing {#zone}

# Conventions and Definitions

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD",
"SHOULD NOT", "RECOMMENDED", "NOT RECOMMENDED", "MAY", and "OPTIONAL" in this
document are to be interpreted as described in BCP 14 [@!RFC2119] [@RFC8174]
when, and only when, they appear in all capitals, as shown here.

# Terminology
Wherever possible we try to follow [@I-D.ietf-dnsop-rfc8499bis].

# Challenges with the current zone file format
## Zone file contents
### $INCLUDE
Include another zone file. See [@RFC1035].
### $ORIGIN
The domain name within which a given relative domain name appears in zone files. See [@RFC1035].
### $GENERATE
Used to create a series of resource records that only differ from each other by an iterator. See [@bind9].
### White space
Both tabs and spaces are used as delimiters and to make the file more readable.
### Parentheses
Parentheses allow RRs to cover multiple lines.
### Comments
Comments begin with a ; and run to the end of the line (see lines 1 and 12 in (#zone)). 
### @
This is the $ORIGIN (see line 17 in (#zone)).
### Empty owner names
The owner name is inherited from the previous line (see line 18 in (#zone)).
### RR formatting
CLASS and TTL are optional according to [@RFC1035]. Might want to check that modern name servers do not expect them.
Some RR types may present their own challenges
#### SVCB
An example can be seen in line 29 and 30 of (#zone) (see [@I-D.ietf-dnsop-svcb-https]). The RData contains key value pairs.

# Improving parsing
TODO: Do we want to use capitalized keywords?

TODO consider the remaning zone file contents described above...
## Parentheses
These MUST not be used. All RRs should be on one line.
## Comments
These MUST restricted to full lines only starting with ; as the first character. Comments on the same line after zone data MUST not be used.
## Changes to to RR formatting
TTL and CLASS MUST NOT be present in any RRs. The $TTL directive SHOULD be used instead or the TTL MAY be a configuration item in the name server. CLASS is always IN.
## SIMD
TODO:

# Security Considerations

There are no security considerations.

# IANA Considerations

This document has no IANA actions.

# Acknowledgments

Thanks to Sara Dickinson for reviewing a very early version of this draft

<reference anchor='simdzone' target='https://fosdem.org/2023/schedule/event/dns_parsing_zone_files_really_fast/attachments/slides/5635/export/events/attachments/dns_parsing_zone_files_really_fast/slides/5635/slides.pdf'>
    <front>
        <title>dns_parsing_zone_files_really_fast</title>
        <author>
            <name>Jeroen Koekkoek</name>
            <organization>NLnet Labs</organization>
        </author>
        <date year='2023'/>
    </front>
</reference>


<reference anchor='nsd' target='https://nsd.docs.nlnetlabs.nl/en/latest/reference/grammar.html'>
<front>
        <title>NSD Documentation</title>
        <author>
          <organization>NLnet Labs</organization>
        </author>
        <date year='2023'/>
    </front>
</reference>

<reference anchor='bind9' target='https://bind9.readthedocs.io/en/latest/chapter3.html#bind-primary-file-extension-the-generate-directive'>
    <front>
        <title>BIND9 ARM</title>
        <author>
          <organization>ISC</organization>
        </author>
        <date year='2023'/>
    </front>
</reference>

{backmatter}